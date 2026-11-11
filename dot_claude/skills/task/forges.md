# Forge commands

The repo's `## Tasks` section names the forge, the repo slug and, on Gitea, the tea login. Below, `<repo>` is the slug, `<login>` the tea login, and `<base>` the Tasks section's base branch, or origin's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, minus `origin/`) when it names none.

On Gitea every command passes `--login <login>`, so issues, comments and PRs come from that account. `git push` still goes over SSH as the owner.

Pass long text through a file. For JSON bodies on Gitea, build them with `jq -n --rawfile body <file> '{body: $body}'` and pipe that to `tea api ... -d @-`.

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
gh issue create --repo <repo> --title "<title>" --body-file <file> [--label <label>]
tea issues create --login <login> --repo <repo> --title "<title>" --description-file <file> [--labels <label>]
```

The command prints the issue's URL. Then run the Tasks section's board command, if it has one.

## Comment on an issue or PR

```sh
gh issue comment <n> --repo <repo> --body-file <file>
jq -n --rawfile body <file> '{body: $body}' | tea api --login <login> -X POST '/repos/<repo>/issues/<n>/comments' -d @-
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
gh pr create --repo <repo> --base <base> --title "<title>" --body-file <file> [--draft]
tea pulls create --login <login> --repo <repo> --base <base> --head <branch> --title "<title>" --description-file <file> [--draft]
```

Gitea marks a draft by prefixing the title with `WIP: `.

## Update a PR's body, or mark a draft ready

```sh
gh pr edit <n> --repo <repo> --body-file <file>
gh pr ready <n> --repo <repo>
jq -n --rawfile body <file> '{body: $body}' | tea api --login <login> -X PATCH '/repos/<repo>/pulls/<n>' -d @-
tea api --login <login> -X PATCH '/repos/<repo>/pulls/<n>' -f title="<title without WIP: >"
```

## Wait for CI

```sh
gh pr checks <n> --repo <repo> --watch
tea api --login <login> '/repos/<repo>/commits/<sha>/status' | jq -r '.state, (.statuses[] | "\(.context): \(.status)")'
```

On Gitea, run the status check again until `state` is no longer `pending`.
