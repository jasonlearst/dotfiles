# Defaults

Override per-project with a repo-level `CLAUDE.md`.

## Workflow
- Ideas and bugs become issues with `/file-issue`. `/worktree <issue>` makes the
  issue's worktree and opens it in its own Workbench tab, where `/task <issue>`
  works it through to the hand-off.
- A repo's facts for those skills (forge, checks, owner tier, hand-off) are in
  the `## Tasks` section of its `CLAUDE.md`.
- A session stays in the folder it started in, so each Workbench tab matches its
  folder. Reach other worktrees with `git -C` and absolute paths, never `cd` or
  `EnterWorktree`.

## Branching
- New work → new branch off `main`, in its own worktree for issue work. Never
  commit to `main` directly.
- Branch: `<type>/<issue>-<descriptive-summary>` for issue work,
  `<type>/<descriptive-summary>` otherwise. The summary says what changes, in
  three to six words.
- `<type>` is the commit prefix (`feat`, `fix`, `ui`, `chore`, `docs`, `dist`,
  `perf`, `refactor`). An issue's label picks it: `bug` → `fix`, `enhancement`
  → `feat` (or `ui` / `perf` when more precise), `chore` → `chore`, `docs` or
  `dist`.

## Commits
- Conventional Commits subjects: `feat(scope): …`, `fix(scope): …`. Scope optional.
- Subject ≤ 70 chars. Body explains *why*, not *what*.
- Trailer: `Co-Authored-By: Claude <model> <noreply@anthropic.com>` —
  fill `<model>` with the model running this session (e.g. `Opus 4.7`).
- Don't touch `CHANGELOG.md` per-commit — generated at release.

## Merging
- Merge only when asked, with `git merge --no-ff -m "Merge <branch>"` into
  `main` unless told otherwise.

## Before committing
- Build clean. Run tests if touching tested code. For UI, launch + verify by hand.

## Confirm before
- `git push`, force-push, deleting un-merged branches, `--no-verify`,
  version bumps, tags, releases, notarization, publishing.
- Exception: in a repo whose hand-off is a PR, `/task` pushes its own branch
  and opens its PR without asking.

## Code style
- No comments unless *why* is non-obvious — identifiers carry the *what*.
- No "added for X" / "used by Y" comments.
- No planning / decision / analysis files unless asked.
