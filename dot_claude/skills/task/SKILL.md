---
name: task
description: Work one issue end to end in its worktree — brief, build, verify, open the PR. Usage: /task <issue>
disable-model-invocation: true
---

If the repo root has its own `.claude/skills/task/SKILL.md`, read it and follow it instead of this file.

Work issue `$ARGUMENTS`. The issue is the brief and the PR is the hand-off; this session's chat is disposable.

Before step 1, read the `## Tasks` section of the repo's root `CLAUDE.md` (forge, setup, checks, owner tier, visibility) and `~/.claude/skills/task/forges.md` (the command for each forge step below). With no Tasks section, stop and offer to draft one as `~/.claude/skills/task/tasks-section.md` describes. In a public repo, `~/.claude/skills/task/public.md` governs every comment, commit message and PR body.

## 1. Worktree

`git rev-parse --show-toplevel` must end in `.claude/worktrees/task-$ARGUMENTS`. Anywhere else, whether the primary checkout or another task's worktree, stop here: tell the user to run `/worktree $ARGUMENTS` in the project's main tab, then `/task $ARGUMENTS` in the tab it opens. A session stays in the folder it started in, so that every tab in Workbench matches the folder it works on.

## 2. Brief

Read the issue with its comments, and look for a PR from this branch. If there's one, you're resuming: read it too. A draft whose body has `## <tier> pending` resumes at that tier in step 4.

Restate the goal and acceptance criteria in a few lines. If the issue has open questions that change what you build, ask them before writing code, then post the questions and answers as a comment on the issue so the brief stays whole. If its cause is graded suspected, confirming it comes first.

Decide whether any criterion needs the owner, from the Tasks section's owner tier and any criterion tagged for it, and say so in the restated goal: which device, roughly how many checks, and how long.

Done when every acceptance criterion is something you can check, and the user knows whether they'll be needed.

## 3. Build

Run the Tasks section's setup for the areas you touch. Read the guides the Tasks section or `CLAUDE.md` names for those areas, then the code. Add or update tests alongside the change; a `fix/` branch adds a test that fails without the fix. Update the docs the Tasks section lists when behaviour changes. Done when the code meets each acceptance criterion and its tests exist.

## 4. Verify

Run the Tasks section's check tiers in order. A tier starts only when the one before it is green, so the owner is never called in for a build a test could have rejected. For a UI change, look at screenshots of every changed screen, light and dark.

Run the owner tier only when step 2 said so. If the Tasks section names a runbook, follow it. Otherwise:

1. Commit, push, and open a draft PR whose body lists the checks under `## <tier> pending`, before asking the owner anything: an unanswered question then loses nothing. With a local hand-off, commit and write the checks to `<tier>-pending.md` in the scratchpad instead.
2. Send a `PushNotification` if the session has that tool, then ask one blocking `AskUserQuestion` with the whole setup: which device, what to connect or unlock, how many checks, how long, and which installed build gets replaced.
3. Give the checks one at a time, waiting for each result.
4. On a failure, fix it, re-run the tiers below that the fix touches, push, and repeat only the affected checks.
5. Replace `## <tier> pending` with `## <tier>` and the results.

Done when every tier the task needs is green and every acceptance criterion has been observed, not assumed.

## 5. Hand off

The Tasks section's hand-off is a PR unless it says local. With a PR hand-off, running `/task` is the go-ahead to push this branch and open its PR. Merging, force-pushing and releases still wait for the user.

With a local hand-off, commit, then report the branch, what changed, the verification, the follow-ups and the worktree's path. The branch stays unpushed until the user asks for the merge; skip the steps below.

1. Commit with Conventional Commit subjects and the session's attribution trailers.
2. `git push -u origin HEAD`.
3. Open the PR against the base branch, or update the draft and mark it ready. The body has: a summary, `Closes #$ARGUMENTS`, what changed per area, verification (commands and results, screens checked, screenshot paths), the owner tier (results, or not needed and why), and anything left for a follow-up issue.
4. If the Tasks section says the repo runs CI, wait for it, and fix and push until it's green.
5. Keep the worktree: the user may test it, and review fixes may follow. `/worktree clean` removes it once the PR is merged.
6. Give the user the PR URL, the follow-ups, the worktree's path, and how to try the change from there. Work the issue raised but didn't ask for goes to `/file-issue`, not into this PR.
