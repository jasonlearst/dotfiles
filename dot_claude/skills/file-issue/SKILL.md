---
name: file-issue
description: Turn a rough idea or bug into a well-specified issue that a fresh /task session can work cold. Usage: /file-issue <idea or what you saw>
disable-model-invocation: true
---

If the repo root has its own `.claude/skills/file-issue/SKILL.md`, read it and follow it instead of this file.

Capture `$ARGUMENTS` as an issue a future session can work cold, with no access to this conversation. Analyse and specify; the fix belongs to `/task`. When `$ARGUMENTS` describes several unrelated problems, give each its own issue.

Investigate read-only: other sessions share this checkout, so its branch and files stay as they are.

Before step 1, read the `## Tasks` section of the repo's root `CLAUDE.md` and `~/.claude/skills/task/forges.md`, which defines `<base>`. With no Tasks section, stop and offer to draft one as `~/.claude/skills/task/tasks-section.md` describes.

1. **Pin down what happened** (bugs). Which screen or action, what the user expected, what they got, and on which device and version. Put any screenshot into words: the issue can't carry images. If you can't name the screen and the expected behaviour, ask one round of questions. Done when someone else could reproduce it from your description.
2. **Locate.** Find the code as it is on `origin/<base>`, whichever branch the checkout is on: `git fetch origin`, then `git grep -n <pattern> origin/<base>` and `git show origin/<base>:<path>`. Note `path:line` for each part, including any other repo or service involved. Read related issues, open and closed. Done when you can name where the current behaviour comes from.
3. **Analyse.** For a bug, find the cause and its evidence: the code path, read-only API calls, logs the user shares. When a test would settle it, write one in a throwaway worktree (`git worktree add --detach <scratchpad>/probe origin/<base>`), run it, keep it for the issue, then `git worktree remove --force <scratchpad>/probe`. Grade the cause **confirmed** (reproduced, or seen in a response or log) or **suspected** (read from code), and name what would confirm a suspicion. For a feature, check whether the code, or a service it relies on, already does it. Done when the cause is confirmed, or the issue says exactly what's left to check.
4. **Write** the body to a scratchpad file, in these sections:
   - **Problem:** the current behaviour and why it falls short, from the user's point of view. For a bug: steps to reproduce, version and device.
   - **Where it comes from:** `path:line` references at the commit `git rev-parse --short origin/<base>` prints. For a bug: the graded cause, its evidence, and the probe test.
   - **Proposed behaviour:** concrete, for each surface it touches.
   - **Acceptance criteria:** a checkbox list, each item observable, including tests and doc updates. Tag an item only the owner can check the way the Tasks section's owner tier says.
   - **Open questions:** the decisions only the user can make, each with your proposed answer.
5. **Sanitize** if the repo is public, as `~/.claude/skills/task/public.md` says.
6. **File** each issue with its own command. The title names the problem or the wish in a few words, as the user would say it. Add the label and board the Tasks section names, if any.
7. **Report** each URL, a two-line summary, and the open questions.
