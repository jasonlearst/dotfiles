#!/usr/bin/env bash
# Exercises worktree.sh in a throwaway clone, once per forge, with `gh` and `tea` stubbed so no real PR is involved.
set -euo pipefail

if [[ -z ${WORKTREE_FORGE:-} ]]; then
  status=0
  for forge in github gitea; do
    echo "== $forge"
    WORKTREE_FORGE=$forge "$0" || status=1
  done
  exit "$status"
fi

script="$(cd "$(dirname "$0")" && pwd)/worktree.sh"
tmp="$(mktemp -d)"
tmp="$(cd "$tmp" && pwd -P)"
sleeper=""
cleanup() {
  if [[ -n $sleeper ]]; then kill "$sleeper" 2>/dev/null || true; fi
  rm -rf "$tmp"
}
trap cleanup EXIT
export WORKTREE_REPO=test/repo

git init --quiet --bare --initial-branch=main "$tmp/origin.git"
git clone --quiet "$tmp/origin.git" "$tmp/repo" 2>/dev/null
cd "$tmp/repo"
git config user.name test
git config user.email test@example.com
printf '*.local\nsecrets/\n' >.gitignore
git add .gitignore
git commit --quiet -m base
git push --quiet origin HEAD:main

mkdir "$tmp/bin"
export PATH="$tmp/bin:$PATH"
pr_rows="$tmp/prs.tsv"
: >"$pr_rows"
printf '#!/bin/sh\ncat "%s"\n' "$pr_rows" >"$tmp/bin/gh"
cat >"$tmp/bin/tea" <<EOF
#!/bin/sh
case "\$*" in
  *page=1*) jq -R -s 'split("\n") | map(select(length > 0) | split("\t")) | map({number: (.[0] | tonumber),
    state: (if .[1] == "OPEN" then "open" else "closed" end), merged: (.[1] == "MERGED"),
    head: {ref: .[2], sha: .[3]}})' "$pr_rows" ;;
  *) echo '[]' ;;
esac
EOF
chmod +x "$tmp/bin/gh" "$tmp/bin/tea"

task() { "$script" new "$1" "chore/$1-case" 2>/dev/null; }
commit_in() { git -C "$1" commit --quiet --allow-empty -m "$2"; }
pr() { printf '%s\t%s\tchore/%s-case\t%s\n' "$1" "$2" "$1" "$3" >>"$pr_rows"; }
head_of() { git -C "$1" rev-parse HEAD; }
pushed_head() { git -C "$1" push --quiet origin HEAD; head_of "$1"; }

failures=0
fail() { echo "FAIL  $1"; failures=$((failures + 1)); }
expect() {
  if grep -q "$2" <<<"$output"; then echo "ok    $1"; else fail "$1: expected '$2'"; fi
}
exists() { [[ -e $1 ]]; }

mkdir secrets
echo key >secrets/api.env
echo cfg >app.local
echo draft >notes.txt
printf '# copied into new worktrees\nsecrets/*.env\napp.local\nnotes.txt\n' >.worktreeinclude

merged="$(task 1)"; commit_in "$merged" work; pr 1 MERGED "$(pushed_head "$merged")"
open="$(task 2)"; commit_in "$open" work; pr 2 OPEN "$(pushed_head "$open")"
closed="$(task 3)"; commit_in "$closed" work; pr 3 CLOSED "$(pushed_head "$closed")"
no_pr="$(task 4)"; commit_in "$no_pr" work
dirty="$(task 5)"; commit_in "$dirty" work; pr 5 MERGED "$(pushed_head "$dirty")"; touch "$dirty/stray"
unpushed="$(task 6)"; commit_in "$unpushed" work; pr 6 MERGED "$(pushed_head "$unpushed")"; commit_in "$unpushed" more
brand_new="$(task 7)"
running="$(task 8)"; commit_in "$running" work; pr 8 MERGED "$(pushed_head "$running")"
(cd "$running" && exec sleep 300) &
sleeper=$!
just_left="$(task 9)"; commit_in "$just_left" work; pr 9 MERGED "$(pushed_head "$just_left")"
local_merge="$(task 14)"; commit_in "$local_merge" work; git merge --quiet --no-ff -m "Merge chore/14-case" chore/14-case
unmerged="$(task 15)"; commit_in "$unmerged" "work on 15"

if [[ $merged == "$tmp/repo/.claude/worktrees/task-1" ]]; then echo "ok    issue worktree is named task-<issue>"; else fail "task 1 landed at $merged"; fi
if exists "$merged/secrets/api.env" && exists "$merged/app.local"; then echo "ok    ignored files in .worktreeinclude copied"; else fail "ignored files not copied"; fi
if exists "$merged/notes.txt"; then fail "untracked but not ignored file copied"; else echo "ok    unignored file not copied"; fi
if [[ -z $(git status --porcelain --ignored=no -- .claude) ]]; then echo "ok    .claude/worktrees hidden from git status"; else fail ".claude/worktrees shows in git status"; fi
if [[ $(grep -c '^/.claude/worktrees/$' .git/info/exclude) == 1 ]]; then echo "ok    exclude added once"; else fail "exclude line count is not 1"; fi

age_agent() { touch -t 202001010000 "$(git -C "$1" rev-parse --absolute-git-dir)"; }
agent() { git worktree add --quiet -b "worktree-agent-$1" ".claude/worktrees/agent-$1" origin/main; echo "$PWD/.claude/worktrees/agent-$1"; }
stale="$(agent stale)"; age_agent "$stale"
fresh="$(agent fresh)"
ahead="$(agent ahead)"; age_agent "$ahead"; commit_in "$ahead" work
pushed="$(agent pushed)"; age_agent "$pushed"; git -C "$pushed" push --quiet origin HEAD
git worktree add --quiet -b chore/elsewhere "$tmp/elsewhere" origin/main
printf '99\tMERGED\tchore/elsewhere\t%s\n' "$(head_of "$tmp/elsewhere")" >>"$pr_rows"

before="$(git worktree list | wc -l)"
output="$("$script" clean)"
expect "dry run names the merged worktree" "would remove .*task-1 "
expect "dry run says nothing was removed" "Dry run"
if [[ $(git worktree list | wc -l) != "$before" ]]; then fail "dry run removed something"; fi

output="$("$script" clean --yes --keep "$just_left")"
echo "$output" | sed 's/^/      /'
expect "primary kept" "keep .*repo: primary checkout"
expect "merged PR removed" "removed .*task-1 and branch chore/1-case: PR #1 merged"
expect "open PR kept" "task-2: PR #2 open"
expect "closed PR kept" "task-3: PR #3 closed unmerged"
expect "no PR kept" "task-4: no PR"
expect "dirty kept" "task-5: uncommitted changes"
expect "unpushed commits kept" "task-6: branch has commits outside merged PR #6"
expect "brand-new worktree kept" "task-7: no PR"
expect "running process kept" "task-8: in use by sleep"
expect "worktree named by --keep kept" "task-9: named by --keep"
expect "stale agent removed" "removed .*agent-stale"
expect "fresh agent kept" "agent-fresh: agent worktree under 24h old"
expect "agent with commits kept" "agent-ahead: agent branch 1 ahead"
expect "pushed agent kept" "agent-pushed: agent branch was pushed"
expect "worktree outside .claude/worktrees kept" "elsewhere: outside .claude/worktrees"
expect "local --no-ff merge removed" "removed .*task-14 and branch chore/14-case: merged into main with --no-ff"
expect "unmerged branch without a PR kept" "task-15: no PR"

if exists "$merged" || git show-ref --quiet refs/heads/chore/1-case; then fail "merged worktree or branch survived"; fi
if ! exists "$open" || ! exists "$brand_new"; then fail "a kept worktree is gone"; fi

occupied="$(task 10)"; commit_in "$occupied" work; pr 10 MERGED "$(pushed_head "$occupied")"
output="$(cd "$occupied" && "$script" clean --yes)"
expect "worktree the script runs in kept" "task-10: in use by"
expect "--keep lasts one run" "removed .*task-9 "
if ! exists "$occupied"; then fail "the worktree the script ran in is gone"; fi

output="$(cd "$occupied" && "$script" new 11 chore/11-case 2>/dev/null)"
expect "new from a worktree lands under the primary" "^$tmp/repo/.claude/worktrees/task-11$"

output="$("$script" new 2 chore/2-case 2>&1)"
expect "existing issue worktree reused" "Reusing .*task-2"

git branch --quiet fix/12-old-name origin/main
git push --quiet origin fix/12-old-name
git branch --quiet -D fix/12-old-name
output="$("$script" new 12 feat/12-new-name 2>&1)"
expect "issue's existing remote branch reused" "already has branch fix/12-old-name"
if [[ $(git -C .claude/worktrees/task-12 branch --show-current) == fix/12-old-name ]]; then echo "ok    task-12 is on the old branch"; else fail "task-12 is on the wrong branch"; fi

git branch --quiet chore/130-other origin/main
output="$("$script" new 13 chore/13-case 2>&1)"
if grep -q "already has branch" <<<"$output"; then fail "issue 13 matched issue 130's branch"; else echo "ok    issue 13 ignores issue 130's branch"; fi

output="$("$script" new probe docs/probe 2>/dev/null)"
expect "named worktree for non-issue work" "^$tmp/repo/.claude/worktrees/probe$"

for bad in "clean --keep" "clean --nope" "new" "new a/b x"; do
  if "$script" $bad 2>/dev/null; then fail "'$bad' was accepted"; else echo "ok    '$bad' rejected"; fi
done

[[ $failures -eq 0 ]] && echo "All cases passed"
exit "$failures"
