# The `## Tasks` section

`/file-issue`, `/worktree` and `/task` take a repo's facts from a `## Tasks` section in its root `CLAUDE.md`. The skills carry the process; this section carries what differs between repos.

To draft one, read the repo: its remote, build and test setup, CI config, any existing `CLAUDE.md` and guides. Show the draft to the user and commit it only once they agree. It goes in a tracked `CLAUDE.md`, since worktrees only get tracked files.

Fields, in this order. Leave out any that don't apply:

- **Forge:** `GitHub <owner/repo>`, or `Gitea <owner/repo>, tea login <login>`.
- **Visibility:** public or private. In a public repo, issues, commit messages and PR bodies are sanitized (`public.md`).
- **Base:** only when work targets something other than origin's default branch.
- **Hand-off:** `local` when the owner merges branches locally instead of reviewing PRs. Leave it out for the default, a PR.
- **Labels:** the labels issues get, such as `bug`, `enhancement`, `chore`, or none.
- **Board:** the command that adds a new issue to a project board, if any.
- **Setup:** what a fresh worktree needs before it builds, such as `npm ci` or `xcodegen generate`. Git-ignored files a worktree needs (`.env.local`, fixtures) go in `.worktreeinclude` at the repo root, one path or glob per line, and `/worktree` copies them.
- **Checks:** each tier in order: its name, its command, and when a task needs it.
- **Owner tier:** what only the owner can check (real devices, hardware), the tag acceptance criteria use for it, and the runbook if there is one.
- **CI:** whether PRs run CI.
- **Docs:** files that change whenever behaviour does, such as `SPEC.md`.
