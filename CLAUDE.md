# dotfiles

The chezmoi source for the owner's dotfiles, applied on macOS, Linux and WSL, on personal and work machines. `README.md` covers installing; `IMPROVEMENTS.md` is the backlog.

## Tasks

The facts `/file-issue`, `/worktree` and `/task` need about this repo. The process lives in those skills.

- **Forge:** GitHub `jasonlearst/dotfiles`.
- **Visibility:** public, and so is every tracked file. Git's name and email come from chezmoi data (`.user`, `.email`, prompted by `.chezmoi.toml.tmpl`), and the ssh config matches hosts by domain, so no addresses land in the repo.
- **Hand-off:** local.
- **Labels:** `bug`, `enhancement`, `chore`.
- **Checks:**
  1. **Fast**, every task, from the worktree root:
     - `chezmoi -S "$PWD" diff <target>…` for each target the change touches, such as `~/.config/fish/config.fish`, shows what applying the branch would change. `chezmoi diff <target>…` without `-S` shows the same for `main`; compare the two so drift already on this Mac isn't taken for the branch's change.
     - Syntax: `fish --no-execute <file>` for fish, `bash -n` or `sh -n` for shell, as the shebang says. Render a template first: `chezmoi -S "$PWD" execute-template < <file>.tmpl | fish --no-execute`. Linux templates read `.chezmoi.osRelease` and don't render on macOS; read those, and leave them to the owner tier.
     - When `dot_claude/skills/worktree/` changes, its test (about 20 seconds). It needs the scripts under their target names:
       ```sh
       d=$(mktemp -d)
       install -m 755 dot_claude/skills/worktree/executable_worktree.sh "$d/worktree.sh"
       install -m 755 dot_claude/skills/worktree/executable_worktree.test.sh "$d/worktree.test.sh"
       "$d/worktree.test.sh"
       ```
  2. **Owner**, the owner tier.
- **Owner tier:** anything seen only in a live app or on another machine. Tag those criteria `[owner]` and name the machine. No runbook.
  - On this Mac: the shell prompt, abbreviations and keybindings, tmux, nvim and vim, Ghostty, macOS defaults, and `run_onchange_` scripts (which install packages). The owner applies the branch's targets with `chezmoi -S <worktree> apply <target>…`, then opens a new shell or app. That leaves the home dir ahead of `main` until the merge; `chezmoi apply <target>…` from `main` puts it back if the branch is dropped.
  - On Linux, WSL or a work machine: these can't run until the branch is merged and pushed, since the branch stays local. List them in the hand-off as checks after the merge, with `chezmoi update` on that machine.
- **Docs:** `IMPROVEMENTS.md`, ticking an item a task finishes; `README.md`, when installing or bootstrapping changes; a skill's `SKILL.md` under `dot_claude/skills/`, when its script's behaviour changes.

### Working in a chezmoi source

- Source names map to targets: `dot_` becomes `.`, `private_` and `executable_` set modes, `.tmpl` renders with chezmoi data, `modify_` filters the file already there, `symlink_` makes a link, and `.chezmoiscripts/` run on apply. `.chezmoiignore` gates targets by OS, `.isWork` and `.isWSL`. A new root file that isn't a dotfile, like `README.md` or this file, needs an entry there or it lands in `~`.
- chezmoi's default source is the primary checkout, which stays on `main`, so pass `-S "$PWD"` to every chezmoi command in a worktree. `chezmoi -S "$PWD" cat <target>` prints a rendered file; run a script or fish function from that copy rather than applying it. `chezmoi -S "$PWD" add <file>` brings a live file into the branch.
- A task never runs `chezmoi apply`, `update`, `re-add`, `edit` or `init`: they write to the live home dir or the primary checkout. Applying belongs to the owner tier.

### Filing issues

- Note the machine: its OS, and `chezmoi data --format json | jq '{isWork, isWSL}'`.
- Check `IMPROVEMENTS.md`. An idea already there is filed from its entry, which has the context, files and approach.
- Then replace that entry's body with a link to the issue, keeping its heading: `Filed as https://github.com/jasonlearst/dotfiles/issues/<n>.` The primary checkout stays untouched, so make the edit with `bash ~/.claude/skills/worktree/worktree.sh new backlog-links docs/link-backlog-to-issues`, which reuses that worktree until it merges, commit it there, and tell the user the branch is waiting to merge.
