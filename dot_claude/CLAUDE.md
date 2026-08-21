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

## Code style
- No comments unless *why* is non-obvious — identifiers carry the *what*.
- No "added for X" / "used by Y" comments.
- No planning / decision / analysis files unless asked.
