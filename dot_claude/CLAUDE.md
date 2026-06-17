# Defaults

Override per-project with a repo-level `CLAUDE.md`.

## Branching
- New work → new branch off `main`. Never commit to `main` directly.
- Branch: `<type>/<kebab-summary>` matching the commit prefix
  (`feat`, `fix`, `ui`, `chore`, `docs`, `dist`, `perf`, `refactor`).

## Commits
- Conventional Commits subjects: `feat(scope): …`, `fix(scope): …`. Scope optional.
- Subject ≤ 70 chars. Body explains *why*, not *what*.
- Trailer: `Co-Authored-By: Claude <model> <noreply@anthropic.com>` —
  fill `<model>` with the model running this session (e.g. `Opus 4.7`).
- Don't touch `CHANGELOG.md` per-commit — generated at release.

## Merging
- `git merge --no-ff -m "Merge <branch>"` into `main`.

## Before committing
- Build clean. Run tests if touching tested code. For UI, launch + verify by hand.

## Confirm before
- `git push`, force-push, deleting un-merged branches, `--no-verify`,
  version bumps, tags, releases, notarization, publishing.

## Running long-lived servers
- Never run dev/test servers as raw background bash — they orphan when the
  session dies (children double-fork and get re-parented to launchd).
- Launch them detached in a named tmux session, prefix `cc-`:
  `tmux new-session -d -s cc-<short-name> 'cd <dir> && <command>'`
- Report the session name and how to watch it: `tmux attach -t cc-<short-name>`
  (detach with Ctrl-b d). Tear down with `tmux kill-session -t cc-<short-name>`.
- `tmux ls` is the full inventory; a `SessionStart` hook sweeps stale `cc-*`
  sessions and orphaned dev servers.
- For docker compose used in testing, run it foreground inside a tmux session
  AND under a project name, both `cc-<name>` (align them):
  `tmux new-session -d -s cc-<name> 'docker compose -p cc-<name> up'`
  Attach to watch/Ctrl-C: `tmux attach -t cc-<name>`. Tear down when done:
  `docker compose -p cc-<name> down -v`. Never leave stacks running past the
  end of your work.
- The tmux session is only a control handle — `tmux kill-session` sends SIGHUP
  and does NOT stop daemon-managed containers (they leak). Only
  `docker compose down` reliably stops them; the `-p cc-<name>` project name is
  what lets the `SessionStart` hook find and tear them down.

## Code style
- No comments unless *why* is non-obvious — identifiers carry the *what*.
- No "added for X" / "used by Y" comments.
- No planning / decision / analysis files unless asked.
