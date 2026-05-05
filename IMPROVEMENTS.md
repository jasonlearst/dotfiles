# Improvements & Open Items

Backlog of dotfiles improvements identified during review sessions. Tick the
checkbox when done. Excluded from `chezmoi apply` via `.chezmoiignore`.

Each item includes: brief context · relevant files · suggested approach · why
it matters. Ordered roughly by leverage.

---

## Multi-OS handling

### [ ] Add Windows (native) support
**Why:** Currently zero coverage. WSL is partially handled via `.isWSL`, but
PowerShell / native Windows tooling has nothing.
**Approach:**
- `dot_config/powershell/Microsoft.PowerShell_profile.ps1.tmpl`
- `.chezmoiscripts/windows/run_onchange_after_install-packages.ps1.tmpl` for
  `winget` or `scoop`
- Branch `[edit]` in `.chezmoi.toml.tmpl` for `code.cmd` on Windows
- gitconfig: `autocrlf = true` on Windows (currently `input` everywhere)

### [ ] Linux distro support: Fedora / Arch / openSUSE
**Why:** Debian/Ubuntu (apt) is now handled by
`.chezmoiscripts/linux/run_onchange_before_install-packages.sh.tmpl`.
Other distros currently print a "skipping" notice.
**Approach:** Extend the `case` in the same script with `dnf` / `pacman` /
`zypper` branches. Package names will differ (e.g. `fd` vs `fd-find`,
`bat` vs `batcat`).

### [ ] Split Brewfile into common / darwin / work
**Why:** `dot_Brewfile` mixes CLI tools (portable) with macOS casks. Hard to
share with Linux/WSL Homebrew.
**Approach:**
- `dot_Brewfile_common` — bat, fzf, ripgrep, fd, jq, etc.
- `dot_Brewfile_darwin` — casks + iOS/cocoapods/duti
- `dot_Brewfile_work.tmpl` gated on `.isWork`
- Update darwin install script to bundle all three

### [ ] Wire `.isWork` into gitconfig email
**File:** `dot_gitconfig.tmpl:3`
**Why:** Right now `.email` is one value across all machines. Most people
want a different commit email on work hosts.
**Approach:** `promptStringOnce` for `workEmail` at init, then
`email = {{ if .isWork }}{{ .workEmail }}{{ else }}{{ .email }}{{ end }}`.

### [ ] Add `.has1Password` flag (or similar) for ssh-config gating
**Why:** The 1Password agent / personal-key lines in
`private_dot_ssh/private_config.tmpl` are currently gated on
`eq .chezmoi.os "darwin"`. That's correct for today's machines (Mac has
1Password, Linux server doesn't), but if 1Password is ever installed on
a Linux desktop the SSH config there would stop using it. Add a
`promptBoolOnce` for `has1Password` and use that as the predicate.

### [ ] Stable SSH_AUTH_SOCK across tmux/mosh reattaches on remote boxes
**Why:** When you reattach to a tmux session that was started by a previous
SSH login, the forwarded `SSH_AUTH_SOCK` path (e.g. `/tmp/ssh-XXXX/agent.NNNN`)
is stale — that socket file is gone with the original ssh process. Git
operations from inside the reattached pane fail with "Could not open a
connection to your authentication agent."
**Approach:** Small login-time script that symlinks the latest forwarded
socket to a stable path (e.g. `~/.ssh/agent.sock`), then a tmux/fish hook
that exports `SSH_AUTH_SOCK` from the symlink. Pattern:
```fish
if test -n "$SSH_AUTH_SOCK"; and test -S "$SSH_AUTH_SOCK"
    ln -sf "$SSH_AUTH_SOCK" "$HOME/.ssh/agent.sock"
end
set -gx SSH_AUTH_SOCK "$HOME/.ssh/agent.sock"
```
Plus tmux: `set -g update-environment "SSH_AUTH_SOCK ..."` so new panes
re-read it.

---

## macOS dotfiles to import

### [ ] VS Code user settings
**Files at:** `~/Library/Application Support/Code/User/{settings.json,keybindings.json}`
**Why:** Settings file has useful `remote.SSH.remotePlatform` host map among
other prefs. Annoying to recreate.
**Approach (pick one):**
- Source-of-truth at `dot_config/Code/User/` plus a darwin `symlink_` from
  `Library/Application Support/Code/User/` to `~/.config/Code/User/`
- Or store directly under `Library/Application Support/Code/User/` (darwin
  only via `.chezmoiignore`)

### [ ] Track Zed settings
**File:** `~/.config/zed/settings.json` (26 lines)
**Approach:** Drop into `dot_config/zed/settings.json`. Trivial.


### [ ] Track htop config
**File:** `~/.config/htop/htoprc` (1.4KB)
**Approach:** `private_dot_config/htop/htoprc` (htop owns it 0600).

### [ ] Add `dot_zshrc` companion to `dot_bash_profile`
**Why:** macOS default shell is zsh. If a script lands in zsh before
exec-ing fish, behavior should match `dot_bash_profile`.
**Approach:** Mirror `dot_bash_profile` structure: source `.profile`,
`.zshrc` interactive bits, then `exec fish` if interactive.

---

## Hygiene / cleanup

### [ ] Try suggested macOS defaults
**File:** `.chezmoiscripts/darwin/run_onchange_after_macos-defaults.sh`
**Why:** Bottom of script has commented-out suggestions (faster key repeat,
smart-quote disable, screenshot redirect, etc.). Uncomment selectively, see
how they feel, keep or revert.

### [ ] `.chezmoiremove` / Brewfile contradiction
**Why:** `.chezmoiremove` deletes `~/.config/nvim`, but `dot_Brewfile` still
installs `neovim`. Pick one direction — either remove `neovim` from Brewfile
or stop removing the config.

### [ ] Empty `.claude/` directory
**Path:** `/Users/jason/.local/share/chezmoi/.claude/` (0 entries)
**Approach:** Delete it, or populate with intended content.

### [ ] Regenerate tailscale completion via run_onchange
**File:** `dot_config/private_fish/completions/tailscale.fish` (230 lines of
generated cobra output)
**Approach:** Drop the static file and add a chezmoi script that runs
`tailscale completion fish > ~/.config/fish/completions/tailscale.fish`
when tailscale is installed (similar pattern to chezmoi.fish.tmpl).

### [ ] Templatize the macOS-only tailscale path
**File:** `dot_config/private_fish/functions/tailscale.fish`
**Why:** Hardcodes `/Applications/Tailscale.app/Contents/MacOS/Tailscale`.
**Approach:** This file is already darwin-gated by `.chezmoiignore`, so the
path is fine — but converting to `.tmpl` and using `{{ .chezmoi.os }}` keeps
it future-proof if tailscale ever ships in `/usr/local/bin`.

### [ ] Trim `dot_config/zellij/config.kdl` to your deltas
**Why:** Whole file is the autogenerated default with everything verbatim
(467 lines). Hard to see what you actually customized.
**Approach:** Keep only `theme "nord"` and any other true overrides.
Survives upstream zellij default changes.

### [ ] Clean up duplicate / corrupted git ignore files
**Files:** `~/.config/git/ignore` (8x repeat of same line, unread because
gitconfig points elsewhere) and `~/.gitignore_global` (3 lines).
**Approach:** Delete `~/.config/git/ignore`; expand `dot_gitignore_global`
with common dev junk (`.idea`, `.vscode`, `.env*`, `.direnv`, language
target dirs).

---

## Adoption strategy (read before importing on other machines)

When adding a dotfile that ALREADY EXISTS on other machines (`.profile`,
`.zshrc`, etc.), `chezmoi apply` will overwrite the existing file with the
template's rendered output. To migrate safely:

1. **On the canonical machine** (this Mac), import the current file:
   ```
   chezmoi add ~/.profile        # copies into source as `dot_profile`
   ```
2. **Inspect on every other machine** before applying:
   ```
   chezmoi diff ~/.profile       # what would change
   chezmoi merge ~/.profile      # 3-way merge if there's drift
   ```
   `chezmoi merge` opens `$EDITOR` (or whatever `merge.command` is set
   to in chezmoi config) with the destination, source, and target — fold
   per-machine bits into the template (or into a sourced `.local` file).

3. **For per-machine additions** (e.g. one server needs an extra PATH
   entry), end the templated file with:
   ```sh
   [ -f ~/.profile.local ] && . ~/.profile.local
   ```
   `.profile.local` stays unmanaged → drift-tolerant.

4. **Distro defaults** (Debian/Ubuntu `.profile`, Fedora `/etc/skel`)
   should be reviewed and folded in. Most ship logic that puts `~/bin`
   and `~/.local/bin` on PATH if they exist; we want to keep that.

5. **Use `--dry-run` with `--verbose`** on the first apply per machine:
   ```
   chezmoi apply --dry-run --verbose
   ```

---

## Done (kept here briefly for context)

- ~~Hardcoded `x86_64` in chezmoi externals~~ — fixed in `7e40454`
- ~~Repeated `kernel.osrelease` / `hostname` checks~~ — `.isWSL`/`.isWork`
  centralized in `7e40454`
- ~~Hardcoded `/Users/jason` in gitconfig~~ — `.chezmoi.homeDir` in `7e40454`
- ~~Track `~/.ssh/config`~~ — added in `3cdf113`
- ~~macOS defaults script~~ — added in `3cdf113`
- ~~Branch `SSH_AUTH_SOCK` per-platform~~ — fish config + chezmoi-managed
  `~/.1password/agent.sock` symlink on macOS
- ~~Track `~/.profile`~~ — added portable `dot_profile`: conditional
  `~/bin` + `~/.local/bin`, guarded cargo env, bashrc source for
  interactive bash, `~/.profile.local` fall-through
- ~~Linux package install for Debian/Ubuntu~~ — added
  `.chezmoiscripts/linux/run_onchange_before_install-packages.sh.tmpl`
  (apt). Other distros remain open (see top section)
- ~~Add zoxide as a chezmoi external for Linux~~ — Mac uses Homebrew
- ~~Gate `dot_config/1Password/`~~ — darwin-only (no longer placed on
  Linux servers)
- ~~Auto-install tmux + vim plugins on config change~~ — added
  `.chezmoiscripts/run_onchange_after_install-{tmux,vim}-plugins.sh.tmpl`,
  hashed against `dot_tmux.conf` / `dot_vimrc` so re-fire is automatic
- ~~README placeholder TODOs~~ — History dropped (git is the history),
  License now references LICENSE.txt
