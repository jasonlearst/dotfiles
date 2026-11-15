# Agent identity

AI agents on this machine (Claude Code) run from your user account, but with
their own identity: their own SSH key, git author, and tool configs, and never
your 1Password agent, keychain logins, or personal configs. It guards against
**accidental** use of your identity. It is not a security boundary: the agent
can still read your whole home directory.

Your own terminals are unchanged: only Claude Code sessions, and commands you
start with `agent-run`, use the agent identity.

## How it's switched on

| Where | How |
|---|---|
| Every Claude Code session | `~/.claude/settings.json` sets `CLAUDE_ENV_FILE` to `~/.agent-identity/activate`, and Claude Code pastes that file ahead of every Bash command. |
| Any other command | `agent-run <command>`, for example `agent-run git push`. On its own, `agent-run` starts an agent shell. |
| A zsh or bash shell | `. ~/.agent-identity/activate` |
| Your own terminals | Nothing. No shell startup file was edited. |

Check any shell with **`agent-whoami`**. It runs offline, never prints a secret,
and exits 1 with `FAIL` lines if anything resolves to your identity.

## What's in here

```
activate              the identity itself (env vars), sourced by everything below
bin/agent-run         run a command under the identity           (on PATH via ~/.local/bin)
bin/agent-whoami      check a shell                              (on PATH via ~/.local/bin)
bin/agent-setup       create this machine's credentials; list what's left
bin/agent-github-app  GitHub App tokens for git and gh; installations, uninstall
bin/agent-gitea-mcp   runs the Gitea MCP server with this machine's Gitea token
bin/as-owner          run one command with your SSH agent and op (see "Acting as you")
lib/real-command      finds the real tool behind a shim: PATH without the shims, then
                      Homebrew's bin and /usr/local/bin
shims/                on PATH only in agent sessions:
  ssh scp sftp          add -F ssh/config
  git                   picks the commit identity per repo (see "Commit identity")
  gh                    runs gh with an app token for the account it targets
  tea                   points tea at xdg/tea
  railway               passes railway/api-token to railway alone
owner-shims/          on PATH only inside as-owner: ssh scp sftp op as you, logged
  op                    refuses unless OP_SERVICE_ACCOUNT_TOKEN is set
ssh/                  config; per machine: id_ed25519_agent_<host>{,.pub}, known_hosts
git/config            GIT_CONFIG_GLOBAL; author and default email from chezmoi data
                      (agentName, agentEmail; `chezmoi init` asks for them)
github-app/           app.env (IDs, allowed accounts), the avatars (avatar-badge.png
                      for GitHub, badge colour #2b3442; avatar.png for Gitea);
                      per machine: private-key.pem, cache/
gh/                   GH_CONFIG_DIR, with a placeholder token
xdg/tea/              per machine: config.yml, one login labelled `claude` (the name
                      repos' Tasks sections use) for Gitea user jasonlearst-agent
railway/              per machine: api-token, a Railway workspace token
gcloud/               CLOUDSDK_CONFIG
npm/npmrc             NPM_CONFIG_USERCONFIG (npm, pnpm, yarn)
docker/config.json    DOCKER_CONFIG, without a keychain credential store
gnupg/                GNUPGHOME, empty
zsh/                  ZDOTDIR: runs your zsh files, then re-applies activate
local.env             per machine: your Gitea SSH host and URL (kept private)
```

## Per tool

- **SSH**: one key, `IdentitiesOnly yes`, `IdentityAgent none`, `SSH_AUTH_SOCK`
  unset. Nothing from `~/.ssh/config` and no host entries. Hosts you already
  trust in `~/.ssh/known_hosts` are read but never written; new host keys go
  to `ssh/known_hosts`.
- **git**: `GIT_CONFIG_GLOBAL` is `git/config` and the system config is skipped
  (it adds osxkeychain). The author, committer, credential helpers and signing
  are also forced at command scope, so a repo's own `.git/config` can't switch
  them back. `GIT_SSH_COMMAND` uses the agent key explicitly.
- **GitHub**: the agent is the GitHub App `jasonlearst-agent` (ID 5764855),
  installed on jasonlearst and Delvelop, and shows as `jasonlearst-agent[bot]`.
  `bin/agent-github-app` signs a short JWT with `github-app/private-key.pem`
  and trades it for a one-hour installation token, only for the accounts in
  `GITHUB_APP_OWNERS`. git talks to GitHub over HTTPS (`git@github.com:`
  remotes are rewritten in agent sessions only) and gets tokens from the
  credential helper. The gh shim picks the account from `-R`, `--repo`,
  `--owner`, a GitHub URL, `gh repo … OWNER/REPO`, `gh api repos|orgs|users/…`,
  `GH_REPO` or the repo's `origin`, and falls back to Delvelop; set
  `AGENT_GITHUB_OWNER=jasonlearst` for anything it can't tell (e.g. GraphQL).
  In `agent` mode (see "Commit identity"), the git shim picks the commit email
  per repo. Where a remote is on GitHub,
  it's the bot's no-reply address
  (`356802260+jasonlearst-agent[bot]@users.noreply.github.com`), so GitHub
  links the commit to jasonlearst-agent[bot] and shows its avatar. Everywhere
  else it's the agent's own address (`agentEmail`), so Gitea links the
  commit to the agent's account and never sees a github.com address. Commits
  made in Gitea and mirrored to GitHub keep that address and show
  there as an unlinked "jasonlearst-agent", since an app's bot can't own any
  other email. Either way the email is forced, so a repo's own `user.email`
  can't win. Pushes, PRs, issues and comments show as jasonlearst-agent[bot].
  Only commands that write commits or tags (and `var`, `config`) pay for the
  remote lookup, about 15 ms; the rest go straight to git.
  gh falls back to your keychain token whenever its config has no token of
  its own, so `gh/hosts.yml` keeps a placeholder: gh run around the shim gets
  a 401 rather than acting as you. Don't log that placeholder out. The shim
  adds `--active` to `gh auth status`, so it shows the app's account and exits
  0 instead of listing the placeholder as a failed login.
- **tea**: the shim sets `XDG_CONFIG_HOME` to `xdg/` for tea only.
- **railway**: the token is a workspace token for Delvelop's projects that
  sees nothing personal, kept in `railway/api-token`. The environment only
  carries a placeholder `RAILWAY_API_TOKEN`, so an `env` dump shows no token
  and railway run around the shim fails instead of falling back to your login
  in `~/.railway`. The railway shim reads the file and hands the token to
  railway alone. A workspace token isn't a person, so CLI commands that look one
  up fail with "Unauthorized": `list`, `project list`, `whoami`, `link` (and so
  `status` and anything that needs a linked folder). What works:
  `railway api '<graphql>'`, commands given explicit IDs
  (`railway logs -p <project> -s <service> -e <env>`), and the `railway` MCP
  server, which Claude Code runs as `agent-run railway mcp` (Railway's hosted
  MCP: projects, services, logs, deployments, variables).
- **gcloud**: `CLOUDSDK_CONFIG`, plus `GOOGLE_APPLICATION_CREDENTIALS` pointing
  inside it, so client libraries fail rather than reading your credentials.
- **npm, pnpm, yarn**: `NPM_CONFIG_USERCONFIG`. bun may ignore it, but you
  have no `~/.npmrc`, and agent-whoami warns if one appears.
- **docker**: its own `DOCKER_CONFIG` (same contexts and plugin folder).
- **gpg**: an empty `GNUPGHOME`.
- **1Password**: `op` is blocked outside `as-owner`. Agent shells get the same
  op:// references your fish shell has, like `SOPS_AGE_KEY_CMD`, from
  `~/.config/op-refs.env` (references, not secrets), so tools such as sops and
  infra's `with-secrets.sh` find them; they only resolve inside `as-owner`.
  Your 1Password configuration is untouched.
- **fish**: `agent-run fish` re-applies the identity after `config.fish`. Fish
  universal variables (like a stale `SOPS_AGE_KEY_CMD`) can't be removed without
  editing `fish_variables`, so the blocked ones are overridden with empty values.

## Commit identity

`agent.commitAs` picks who commits, per repo: `owner` is you, with the name and
email your own git uses there (the repo's `user.email`, else `~/.gitconfig`);
`agent` is jasonlearst-agent (the bot's no-reply address in GitHub repos,
its own `agentEmail` address elsewhere). The default, in `git/config`, is `owner`:
work you direct is yours, even when you drive it from your phone. A repo where
Claude works unattended switches to the agent with
`git config --local agent.commitAs agent`.
Either way the identity is forced, Claude stays a co-author through the commit
trailer, and pushes, PRs and issues still go through the agent's credentials.
An upstream pull request has to be opened by you: the GitHub App isn't
installed on other people's repos.

## Acting as you: as-owner

    as-owner --why "upgrade Gitea and runners" -- just gitea

Runs one command, and everything it starts, with your 1Password SSH agent and
the real `op` in front of the agent's shims: `ssh`, `scp`, `sftp` and `op` are
yours (your `~/.ssh/config`, no agent forwarding, no password fallback), while
git, gh, tea and railway stay the agent's. 1Password asks for your approval,
so it works only while you're at the Mac; away, the prompt goes unanswered and
the command fails. `--why` is required. A run is capped at 30 minutes
(`--max 90s`, `--max 2h`), Ansible's shared ssh connections are closed when it
ends (infra's ControlPersist would keep them logged in as you for 30 minutes),
and if `op` was used, `op signout` ends its authorization so the next run asks
again. Each run, and each ssh and op call in it, is logged to
`~/Library/Logs/agent-identity/as-owner.log` and the macOS log:
`/usr/bin/log show --last 1d --predicate 'eventMessage BEGINSWITH "as-owner "'`.
Claude Code always asks before running `as-owner`, and before the direct
bypasses (`SSH_AUTH_SOCK=…`, `/usr/bin/ssh`, `/usr/local/bin/op`).

What it weakens, by design: during a run, that process tree is you over SSH
(root on hosts, with your keys) and can hold your secrets, such as the vault
password and the SOPS age key, which decrypts every SOPS secret in infra. The
agent writes the command, so read Claude's prompt before approving:
1Password's prompt only says "ssh" or "op", not what's running. Depending on
1Password's "remember key approval" setting, a second run soon after may not
ask again. Like everything here, it's scripts the agent could edit, not a
security boundary.

## Giving the agent access

- **SSH key** (servers; each machine's key is already on Gitea's
  jasonlearst-agent account): add `ssh/id_ed25519_agent_<host>.pub`. Your
  machine inventory (see "If a machine is lost") has each key's fingerprint.
- **GitHub**: through the app; don't run `gh auth login` as the agent. Change
  repos or permissions at Settings → Applications → Installed GitHub Apps →
  jasonlearst-agent → Configure (and in Delvelop's org settings). The app is
  public, so check now and then that nobody else installed it:
  `agent-github-app installations` (exits 3 and names any stranger), and
  remove one with `agent-github-app uninstall <id>`.
- **Gitea**: the agent is the user jasonlearst-agent, with the `agentEmail`
  address, so Gitea links its commits to that account. Each
  machine has its own SSH key and its own API token; the token lives only in
  that machine's tea login, which the Gitea MCP server reads through
  `agent-gitea-mcp`. The account has write access as a collaborator on the
  repos it works in.
- **railway**: to rotate a machine's token, create a new workspace token,
  replace `railway/api-token`, and revoke the old one in Railway's Account
  Settings → Tokens.
- **gcloud**: `agent-run gcloud auth login`, or a service-account key.
- **1Password**: set `OP_SERVICE_ACCOUNT_TOKEN` for an agent service account.

## Not covered

- MCP servers bring their own credentials. `gitea` (`agent-run agent-gitea-mcp
  …`) and `railway` (`agent-run railway mcp`) run as the agent. claude.ai
  connectors and local MCP servers for your own data use your own logins and
  act as you.
- `CLAUDE_ENV_FILE` covers Claude's Bash commands. It doesn't cover Claude
  Code's own processes: hooks, MCP servers, and its internal git/gh calls.
  Anything agent-like started outside Claude Code runs as you unless it goes
  through `agent-run`.
- GitHub Apps can't reach projects owned by a personal account (only org
  projects), gists, or the ghcr.io container registry (publish images from
  GitHub Actions instead). An org project can only take items from repos the
  Delvelop installation can see.

## chezmoi and new machines

The dotfiles repo manages everything here except the per-machine files marked
above: the SSH key, `known_hosts`, the GitHub App key, the Railway token, the
tea login and `local.env`. Those never leave their machine, and its
`.chezmoiignore` keeps them out of the source. `activate`, `ssh/config` and
`git/config` take the hostname from chezmoi, so each machine uses its own key.

On a new machine, `chezmoi apply` creates the folder and runs `agent-setup`,
which makes the SSH key and lists the rest (each step names its credential
after the machine). Run `agent-setup` again until it reports nothing left, add
the machine to your machine inventory, then check with `agent-run agent-whoami`.

Run chezmoi only from your own terminal, never from an agent session: it
renders templates with the environment it runs in, and the agent's would leak
into your files. `chezmoi verify` exits non-zero if anything managed here has
drifted from the source, including the agent editing its own identity.

## If a machine is lost

Every credential the agent holds lives only on its own machine and is named
after it, so a lost or compromised machine means revoking just its set, from
any other device. The other machines keep working.

1. **Gitea SSH key:** as jasonlearst-agent (or as admin), delete the SSH key
   titled `agent-identity <machine> (<date>)`.
2. **GitHub App key:** github.com/settings/apps/jasonlearst-agent → Private
   keys → delete the key with that machine's fingerprint.
3. **Railway token:** Account Settings → Tokens → delete
   `jasonlearst-agent <machine>`.
4. **Gitea API token:** jasonlearst-agent → Settings → Applications → delete
   the machine's token.
5. **Servers and other machines:** remove the `authorized_keys` line ending in
   `agent@<machine>` wherever that machine's key was accepted.

Which machines exist, their key fingerprints and token names, and which hosts
accept which machine's key are in your machine inventory: a 1Password secure
note, kept out of this public repo, that you can reach from any device.

## Editing

`activate` is read-only (0400), so no hook can append to it. Edit it in the
dotfiles repo, not here: chezmoi would overwrite a local change. The git name
and email live only in `git/config`; `activate` reads them from there.

## Undo

1. In `~/.claude/settings.json`, under `env`, delete the `CLAUDE_ENV_FILE`
   line, then restart your Claude tabs. (With chezmoi, also drop the agent
   identity from the dotfiles repo, or its modify script puts the line back.)
2. `rm ~/.local/bin/agent-run ~/.local/bin/agent-whoami ~/.local/bin/agent-setup ~/.local/bin/agent-github-app`
3. Remove the agent's public keys everywhere you added them, and revoke any
   tokens you gave the agent.
4. Delete the GitHub App: Settings → Developer settings → GitHub Apps →
   jasonlearst-agent → Advanced → Delete. That removes both installations.
5. `rm -rf ~/.agent-identity`
