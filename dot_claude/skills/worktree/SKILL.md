---
name: worktree
description: Make a worktree for an issue and open it in its own Workbench tab, or list and clean up worktrees. Usage: /worktree <issue> | /worktree <name> <branch> | /worktree list | /worktree clean
disable-model-invocation: true
---

If the repo's `CLAUDE.md` says how its worktrees are made (its own script, a map of several repos), follow that instead of this file.

`~/.claude/skills/worktree/worktree.sh` does the git work; run it from any checkout of the repo. This session stays in the folder it started in: the work happens in a new session that starts inside the worktree, so Workbench's tabs and Claude Code's permissions both match the folder each session works on.

Read the `## Tasks` section of the repo's root `CLAUDE.md` first. On Gitea, put its tea login in front of every script call as `TEA_LOGIN=<login>`, and use `~/.claude/skills/task/forges.md` for forge commands. With no Tasks section, stop and offer to draft one as `~/.claude/skills/task/tasks-section.md` describes.

## `/worktree <issue>`

1. Read the issue's title, state and labels. If it's closed, ask before going on.
2. Name the branch as the Branching section of `~/.claude/CLAUDE.md` says: `<type>/<issue>-<descriptive-summary>`, with the type picked from the issue's label.
3. Run `bash ~/.claude/skills/worktree/worktree.sh new <issue> <branch>`. It fetches origin, then reuses the issue's worktree, or a branch that already exists for the issue, before making a new branch from origin's default branch at `.claude/worktrees/task-<issue>`. It keeps `.claude/worktrees/` out of `git status`, copies the git-ignored files `.worktreeinclude` lists, and prints the worktree's path last.
4. Run `bench add "<path>"` unless `bench projects` already lists that path. It opens a Workbench tab with Claude in the worktree. Skip this on a machine without `bench`.
5. Report the path, the branch, anything reused or copied, and the next step: `/task <issue>` in the new tab.

## `/worktree <name> <branch>`

For work without an issue. Skip steps 1 and 2, and pass the name instead of an issue number: the worktree goes to `.claude/worktrees/<name>`.

## `/worktree list` and `/worktree clean`

`list` shows each worktree with its PR, status, size and verdict. `clean` without `--yes` is a dry run: show the user what it would remove, and run it with `--yes` once they agree, adding `--keep <path>` for each worktree they want spared. It removes a worktree and its branch only when the branch is merged (its PR merged with the same head commit, or the head merged into the base branch with `--no-ff`), nothing is uncommitted, and no process has files open inside it. Report what was removed.
