---
name: tasks-setup
description: Give a repo the `## Tasks` section the shared /file-issue, /worktree and /task skills read, migrating any project copies of those skills into it. Usage: /tasks-setup
disable-model-invocation: true
---

Set this repo up for the shared `/file-issue`, `/worktree` and `/task` skills. They carry the process; the repo's `## Tasks` section carries its facts. A repo's own `.claude/skills/file-issue` or `.claude/skills/task` takes the shared skill's place, so setup also migrates those copies: what's specific to the repo moves into the Tasks section, and the copies go.

Before step 1, read `~/.claude/skills/task/tasks-section.md`, which defines the section's fields, then `forges.md` and `public.md` beside it, and the `SKILL.md` of `file-issue`, `worktree` and `task` under `~/.claude/skills/`, so you know what the shared process already covers.

This session stays in the folder it started in: reach the worktree with absolute paths and `git -C`.

1. **Worktree.** Run `bash ~/.claude/skills/worktree/worktree.sh new tasks-setup <branch>`. The branch is `chore/move-to-shared-task-skills` when the repo has project copies to migrate, and `docs/add-tasks-section` otherwise. Done when it prints the worktree's path.

2. **Survey** the repo in the worktree, which is at origin's default branch: remotes, build and test setup, CI config, `CLAUDE.md` and every guide it names, `.gitignore`, the project copies of the skills and every file they point at, and any script or doc about issues, tasks or worktrees. If the repo already has a Tasks section, compare it with `tasks-section.md` and change only what's missing or stale. Done when you can fill each field `tasks-section.md` lists, or say why it doesn't apply, from what you've read rather than guessed.

3. **Draft** the Tasks section in the worktree's root `CLAUDE.md`, creating the file if there's none; it must be tracked, since worktrees only get tracked files. Use the fields and order `tasks-section.md` gives, with commands as the repo runs them and paths that exist. A fact a session needs that no field holds, such as how to run the app for a check or what to gather when filing an issue, goes in a short `###` subsection under `## Tasks`. Done when every field is filled or left out on purpose.

4. **Migrate** the project copies, if there are any. Account for every line of them, sorting each into one of three:
   - **Repo fact** (a command, check tier, port, fixture, owner-tier trigger or tag, filing hint): move it into the Tasks section.
   - **Shared process** the shared skills already cover: drop it.
   - **Missing process**, which the shared skills lack: keep it in the Tasks section when it's about this repo, and list it for the user as a candidate for the shared skills when it isn't.

   Then:
   - Move an owner-tier runbook to `.claude/<tier>-checks.md` and name it in the Owner tier field. It replaces `/task`'s generic owner-tier steps, so keep its order, check format and PR section, and write its PR steps forge-neutral ("open the PR as a draft").
   - `git rm` the project skill directories.
   - Remove a project worktree script when the shared `worktree.sh` does what it does, and list the git-ignored files it copied in `.worktreeinclude` under the comment `# Git-ignored files that /worktree copies into a new worktree, one path or glob per line.` When the shared script can't do the job (several repos, another layout), keep the script and say in `CLAUDE.md` how worktrees are made.
   - Sessions now start inside their worktree, so remove rules written for sessions that entered one with `EnterWorktree`, and comments that explain code by those rules. Remove lines that repeat `~/.claude/CLAUDE.md`. Keep the repo's own public-repo rules: `public.md` applies them on top of its own.

   Done when every line of the old copies is moved, dropped as shared process, or listed for the user.

5. **Check.** `git -C <worktree> grep` finds no reference to a removed file, skill path or `EnterWorktree`. `bash ~/.claude/skills/worktree/worktree.sh list`, run from the repo, reads its worktrees and PRs, with `TEA_LOGIN=<login>` in front on Gitea. When anything beyond docs changed, such as a removed script that a test runner or CI might call, run the repo's fast check tier. Done when all three pass.

6. **Review.** Show the user the Tasks section, any runbook, the files removed, and the lines you dropped or listed. Done when they agree, or their changes are made and they agree to those.

7. **Commit** with a Conventional Commit subject and the session's attribution trailers; in a public repo, sanitize the message as `public.md` says. Pushing, opening a PR and merging each wait for the user's go-ahead. Report the branch, the worktree's path, any missing process you listed, and that the primary checkout keeps running its old project copies until this branch merges. `/worktree clean` removes the worktree after that.
