#!/usr/bin/env bash
# One worktree per task under <primary checkout>/.claude/worktrees/, made from any checkout so no session has to move.
# Usage: worktree.sh new <issue|name> <branch> | list | clean [--yes] [--keep <path>]
# The forge and repo come from origin, the base from origin/HEAD. Overrides: WORKTREE_FORGE (github|gitea),
# WORKTREE_REPO (owner/repo), WORKTREE_BASE (e.g. origin/develop), TEA_LOGIN (tea login for Gitea).
# A PR doesn't exist when a worktree is created, so worktrees are named by issue and matched to PRs by branch.
set -euo pipefail

AGENT_MIN_AGE_SECONDS=$((24 * 60 * 60))

die() { echo "worktree.sh: $*" >&2; exit 1; }

primary="$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')"
[[ -n $primary ]] || die "not inside a git repository"
origin_url="$(git -C "$primary" remote get-url origin 2>/dev/null)" || die "no origin remote"

REPO="${WORKTREE_REPO:-$(sed -E 's#^[a-z+]+://[^/]+/##; s#^[^@/]+@[^:]+:##; s#\.git$##' <<<"$origin_url")}"
host="$(sed -E 's#^[a-z+]+://([^@/]*@)?([^/:]+).*#\2#; s#^[^@/]+@([^:]+):.*#\1#' <<<"$origin_url")"
if [[ -n ${WORKTREE_FORGE:-} ]]; then FORGE="$WORKTREE_FORGE"
elif [[ $host == github.com ]]; then FORGE=github
else FORGE=gitea
fi
base="${WORKTREE_BASE:-$(git -C "$primary" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main)}"

worktrees() {
  git worktree list --porcelain | awk '
    /^worktree / { path = substr($0, 10); branch = "-"; state = "-" }
    /^branch /   { branch = substr($0, 19) }
    /^locked/    { state = "locked" }
    /^prunable/  { state = "prunable" }
    /^$/         { print path "\t" branch "\t" state }'
}

ensure_ignored() {
  mkdir -p "$primary/.claude/worktrees"
  if ! git -C "$primary" check-ignore -q .claude/worktrees; then
    local exclude
    exclude="$(git -C "$primary" rev-parse --path-format=absolute --git-common-dir)/info/exclude"
    mkdir -p "$(dirname "$exclude")"
    echo "/.claude/worktrees/" >>"$exclude"
    echo "Ignored .claude/worktrees/ in $exclude" >&2
  fi
}

# Copies the git-ignored files that .worktreeinclude names (paths or globs, one per line) into a new worktree.
copy_included() {
  local dest="$1" list="$primary/.worktreeinclude" pattern source rel IFS=$'\n'
  [[ -f $list ]] || return 0
  while IFS= read -r pattern || [[ -n $pattern ]]; do
    pattern="${pattern%/}"
    [[ -z $pattern || $pattern == \#* ]] && continue
    for source in "$primary"/$pattern; do
      [[ -e $source ]] || continue
      rel="${source#"$primary"/}"
      git -C "$primary" check-ignore -q -- "$rel" || continue
      [[ -e $dest/$rel ]] && continue
      mkdir -p "$(dirname "$dest/$rel")"
      cp -Rp "$source" "$dest/$rel"
      echo "Copied $rel" >&2
    done
  done <"$list"
}

cmd_new() {
  [[ $# -eq 2 ]] || die "usage: new <issue|name> <branch>"
  local name="${1#\#}" branch="$2" issue="" path existing other
  [[ $name =~ ^[A-Za-z0-9._-]+$ ]] || die "not an issue number or name: $1"
  if [[ $name =~ ^[0-9]+$ ]]; then issue="$name" name="task-$name"; fi
  path="$primary/.claude/worktrees/$name"

  git -C "$primary" fetch --quiet origin
  ensure_ignored

  if [[ -n $issue ]] && ! git show-ref --quiet --verify "refs/heads/$branch" \
    && ! git show-ref --quiet --verify "refs/remotes/origin/$branch"; then
    other="$( {
      git for-each-ref --format='%(refname:lstrip=2)' "refs/heads/*/$issue-*"
      git for-each-ref --format='%(refname:lstrip=3)' "refs/remotes/origin/*/$issue-*"
    } | head -n 1)"
    if [[ -n $other ]]; then
      echo "Issue $issue already has branch $other; using it instead of $branch" >&2
      branch="$other"
    fi
  fi

  existing="$(worktrees | awk -F'\t' -v p="$path" -v b="$branch" '$1 == p || $2 == b { print $1; exit }')"
  if [[ -n $existing ]]; then
    echo "Reusing $existing" >&2
    path="$existing"
  elif git show-ref --quiet --verify "refs/heads/$branch"; then
    git worktree add --quiet "$path" "$branch"
  elif git show-ref --quiet --verify "refs/remotes/origin/$branch"; then
    git worktree add --quiet --track -b "$branch" "$path" "origin/$branch"
  else
    git worktree add --quiet --no-track -b "$branch" "$path" "$base"
  fi

  copy_included "$path"
  echo "$path"
}

# One TSV row per PR: number, OPEN|CLOSED|MERGED, head branch, head commit.
pr_rows() {
  if [[ $FORGE == github ]]; then
    gh pr list --repo "$REPO" --state all --limit 1000 --json number,state,headRefName,headRefOid \
      --jq '.[] | [.number, .state, .headRefName, .headRefOid] | @tsv'
    return
  fi
  local page rows
  for ((page = 1; page <= 100; page++)); do
    rows="$(tea api ${TEA_LOGIN:+--login "$TEA_LOGIN"} "/repos/$REPO/pulls?state=all&limit=50&page=$page" \
      | jq -r '.[] | [.number, (if .merged then "MERGED" elif .state == "open" then "OPEN" else "CLOSED" end), .head.ref, .head.sha] | @tsv')" \
      || return 1
    [[ -n $rows ]] || return 0
    echo "$rows"
  done
}

load_remote_state() {
  git -C "$primary" fetch --quiet origin
  remote_heads="$(git ls-remote --heads origin)" || die "can't read origin"
  prs="$(pr_rows)" || die "can't read PRs from $FORGE ($REPO)"
  # Heads merged with --no-ff are the non-first parents of merge commits on the base, locally or on origin.
  local main_refs=("$base")
  if git show-ref --quiet --verify "refs/heads/${base#origin/}"; then main_refs+=("${base#origin/}"); fi
  merged_heads="$(git rev-list --merges --parents "${main_refs[@]}" | cut -d' ' -f3- | tr ' ' '\n')"
  open_files="$(lsof -n -P -Fpcn 2>/dev/null | awk '
    /^p/ { pid = substr($0, 2) }
    /^c/ { cmd = substr($0, 2) }
    /^n/ { print cmd "(" pid ")\t" substr($0, 2) }')" || true
  [[ -n $open_files ]] || die "lsof returned nothing, so running processes can't be ruled out"
}

processes_in() {
  awk -F'\t' -v w="$1" '($2 == w || index($2, w "/") == 1) && !seen[$1]++ && n++ < 3 { printf "%s ", $1 }' <<<"$open_files"
}

# Newest PR for the branch, or an open one if any exists. Sets pr_number, pr_state, pr_head.
find_pr() {
  local line
  pr_number="" pr_state="" pr_head=""
  line="$(awk -F'\t' -v b="$1" '$3 == b && (!n++ || $2 == "OPEN") { line = $0 } END { print line }' <<<"$prs")"
  IFS=$'\t' read -r pr_number pr_state _ pr_head <<<"$line" || true
}

# Sets verdict (remove|keep), reason, pr_label and status for one worktree.
judge() {
  local path="$1" branch="$2" state="$3" admin_dir age ahead processes
  verdict=keep reason="" pr_label="-" status="-"

  if [[ $path == "$primary" ]]; then reason="primary checkout"; return; fi
  if [[ $state == prunable ]]; then reason="directory is gone (git worktree prune)"; return; fi

  find_pr "$branch"
  if [[ -n $pr_number ]]; then pr_label="#$pr_number $pr_state"; fi

  local dirty=""
  dirty="$(git -C "$path" status --porcelain)"
  if [[ -n $dirty ]]; then
    status="dirty"
  elif [[ $branch != "-" ]]; then
    local unpushed
    unpushed="$(git rev-list --count "$branch" --not --remotes=origin)"
    if [[ $unpushed -gt 0 ]]; then status="$unpushed local-only"; else status="clean"; fi
  fi

  # Older worktrees live elsewhere, and this script didn't create them.
  if [[ $path != "$primary/.claude/worktrees/"* ]]; then reason="outside .claude/worktrees"; return; fi
  if [[ $state == locked ]]; then reason="locked"; return; fi
  if [[ $branch == "-" ]]; then reason="detached HEAD"; return; fi
  if [[ -n $dirty ]]; then reason="uncommitted changes"; return; fi
  processes="$(processes_in "$path")"
  if [[ -n $processes ]]; then reason="in use by ${processes% }"; return; fi

  if [[ $branch == worktree-agent-* ]]; then
    ahead="$(git rev-list --count "$base..$branch")"
    admin_dir="$(git -C "$path" rev-parse --absolute-git-dir)"
    age=$(($(date +%s) - $(stat -f %B "$admin_dir")))
    if [[ $ahead -gt 0 ]]; then reason="agent branch $ahead ahead of $base"
    elif grep -q "refs/heads/$branch\$" <<<"$remote_heads"; then reason="agent branch was pushed"
    elif [[ $age -le $AGENT_MIN_AGE_SECONDS ]]; then reason="agent worktree under 24h old"
    else verdict=remove reason="stale agent worktree"
    fi
    return
  fi

  case "$pr_state" in
    "")
      if grep -qx "$(git rev-parse "$branch")" <<<"$merged_heads"; then
        verdict=remove reason="merged into ${base#origin/} with --no-ff"
      else
        reason="no PR"
      fi
      ;;
    OPEN) reason="PR #$pr_number open" ;;
    CLOSED) reason="PR #$pr_number closed unmerged" ;;
    MERGED)
      if [[ $(git rev-parse "$branch") == "$pr_head" ]]; then
        verdict=remove reason="PR #$pr_number merged"
      else
        reason="branch has commits outside merged PR #$pr_number"
      fi
      ;;
    *) reason="unknown PR state $pr_state" ;;
  esac
}

display_path() { echo "${1#"$(dirname "$primary")/"}"; }

cmd_list() {
  load_remote_state
  {
    printf 'WORKTREE\tBRANCH\tPR\tSTATUS\tSIZE\tVERDICT\n'
    while IFS=$'\t' read -r path branch state <&3; do
      judge "$path" "$branch" "$state"
      local size="-"
      if [[ -d $path ]]; then size="$(du -sh "$path" | cut -f1 | tr -d ' ')"; fi
      printf '%s\t%s\t%s\t%s\t%s\t%s: %s\n' "$(display_path "$path")" "$branch" "$pr_label" "$status" "$size" "$verdict" "$reason"
    done 3< <(worktrees)
  } | column -t -s $'\t'
}

cmd_clean() {
  local yes="" spared=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes) yes=1 ;;
      --keep) [[ $# -ge 2 ]] || die "usage: clean [--yes] [--keep <path>]"; spared="$2"; shift ;;
      *) die "usage: clean [--yes] [--keep <path>]" ;;
    esac
    shift
  done
  load_remote_state

  local removed=0
  while IFS=$'\t' read -r path branch state <&3; do
    judge "$path" "$branch" "$state"
    # A session that has just left a worktree holds nothing open there, so the in-use check can't protect it.
    if [[ $path == "$spared" ]]; then verdict=keep reason="named by --keep"; fi
    if [[ $verdict == keep ]]; then
      echo "keep    $(display_path "$path"): $reason"
    elif [[ -z $yes ]]; then
      echo "would remove $(display_path "$path") and branch $branch: $reason"
    else
      git worktree remove "$path"
      git branch --quiet -D "$branch"
      echo "removed $(display_path "$path") and branch $branch: $reason"
      removed=$((removed + 1))
    fi
  done 3< <(worktrees)
  if [[ -n $yes ]]; then echo "$removed removed"; else echo "Dry run: nothing removed. Pass --yes to remove."; fi
}

case "${1:-}" in
  new) shift; cmd_new "$@" ;;
  list) cmd_list ;;
  clean) shift; cmd_clean "$@" ;;
  *) die "usage: new <issue|name> <branch> | list | clean [--yes] [--keep <path>]" ;;
esac
