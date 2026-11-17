# Forge commands

The repo's `## Tasks` section names the forge, the repo slug and, on Gitea, the tea login. Below, `<repo>` is the slug, `<login>` the tea login, and `<base>` the Tasks section's base branch, or origin's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, minus `origin/`) when it names none. `<owner>` is the Tasks section's owner login, or the account in `<repo>` when it names none.

The agent posts under its own account, and the owner gets no notification for an issue or PR they aren't assigned to, asked to review or mentioned in. So every new issue is assigned to `<owner>`, and every PR is assigned to `<owner>` with their review requested.

On Gitea every command passes `--login <login>`, so issues, comments and PRs come from that account. `git push` goes over SSH as that account too: Claude Code runs every command under the agent identity in `~/.agent-identity`, whose SSH key belongs to it. The account needs write access to the repo.

Pass long text through a file. For JSON bodies on Gitea, build them with `jq -n --rawfile body <file> '{body: $body}'` and pipe that to `tea api ... -d @-`. Leave the write paths below unquoted, as shown: that's the form `~/.claude/settings.json` allows without a prompt.

## Read an issue, with its comments

```sh
gh issue view <n> --repo <repo> --json title,state,labels,body,comments --jq '.title, .state, ([.labels[].name] | join(", ")), .body, (.comments[] | .body)'
```

`gh issue view --comments` prints only the comments when not run in a terminal, and nothing at all if there are none, so use the `--json` form above.

```sh
tea api --login <login> '/repos/<repo>/issues/<n>' | jq -r '.title, .state, ([.labels[].name] | join(", ")), .body'
tea api --login <login> '/repos/<repo>/issues/<n>/comments' | jq -r '.[] | "--- \(.user.login):", .body'
```

## Search issues, open and closed

```sh
gh issue list --repo <repo> --state all --search "<words>"
tea issues list --login <login> --repo <repo> --state all --keyword "<words>"
```

## File an issue

```sh
gh issue create --repo <repo> --title "<title>" --body-file <file> --assignee <owner> [--label <label>]
tea issues create --login <login> --repo <repo> --title "<title>" --description-file <file> --assignees <owner> [--labels <label>]
```

The command prints the issue's URL. Then run the Tasks section's board command, if it has one.

## Comment on an issue or PR

```sh
gh issue comment <n> --repo <repo> --body-file <file>
jq -n --rawfile body <file> '{body: $body}' | tea api --login <login> -X POST /repos/<repo>/issues/<n>/comments -d @-
```

## Find this branch's PR

```sh
gh pr list --repo <repo> --state all --head <branch> --json number,state,isDraft,url
tea api --login <login> '/repos/<repo>/pulls?state=all&limit=50' | jq -r '.[] | select(.head.ref == "<branch>") | "#\(.number) \(.state) merged=\(.merged) \(.title)"'
```

## Read a PR, with comments and reviews

```sh
gh pr view <n> --repo <repo> --json title,state,isDraft,body,comments,reviews --jq '.title, .state, .body, (.comments[] | .body), (.reviews[] | .body)'
tea api --login <login> '/repos/<repo>/pulls/<n>' | jq -r '.title, .state, .body'
tea api --login <login> '/repos/<repo>/issues/<n>/comments' | jq -r '.[] | "--- \(.user.login):", .body'
tea api --login <login> '/repos/<repo>/pulls/<n>/reviews' | jq -r '.[] | "--- \(.user.login) \(.state):", .body'
```

## Open a PR

Push the branch first.

```sh
gh pr create --repo <repo> --base <base> --title "<title>" --body-file <file> --assignee <owner> --reviewer <owner> [--draft]
tea pulls create --login <login> --repo <repo> --base <base> --head <branch> --title "<title>" --description-file <file> --assignees <owner> [--draft]
jq -n --arg owner <owner> '{reviewers: [$owner]}' | tea api --login <login> -X POST /repos/<repo>/pulls/<n>/requested_reviewers -d @-
```

`tea pulls create` can't request a review, so on Gitea the second command does it.

## Assign the owner and request their review on an existing PR

For a PR opened before this rule, or one missing either.

```sh
gh pr edit <n> --repo <repo> --add-assignee <owner> --add-reviewer <owner>
jq -n --arg owner <owner> '{assignees: [$owner]}' | tea api --login <login> -X PATCH /repos/<repo>/issues/<n> -d @-
jq -n --arg owner <owner> '{reviewers: [$owner]}' | tea api --login <login> -X POST /repos/<repo>/pulls/<n>/requested_reviewers -d @-
```

Gitea marks a draft by prefixing the title with `WIP: `.

## Update a PR's body, or mark a draft ready

```sh
gh pr edit <n> --repo <repo> --body-file <file>
gh pr ready <n> --repo <repo>
jq -n --rawfile body <file> '{body: $body}' | tea api --login <login> -X PATCH /repos/<repo>/pulls/<n> -d @-
tea api --login <login> -X PATCH /repos/<repo>/pulls/<n> -f title="<title without WIP: >"
```

## Wait for CI

```sh
gh pr checks <n> --repo <repo> --watch
tea api --login <login> '/repos/<repo>/commits/<sha>/status' | jq -r '.state, (.statuses[] | "\(.context): \(.status)")'
```

On Gitea, run the status check again until `state` is no longer `pending`.
