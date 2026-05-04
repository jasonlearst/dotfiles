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

### [ ] Linux distro detection / package install
**Why:** On Linux, chezmoi externals download `eza/zellij/jj/mcfly/tere`, but
`fish`, `bat`, `ripgrep`, `fd`, `direnv`, `git`, `tmux` are assumed present.
**Approach:**
- `.chezmoiscripts/linux/run_onchange_before_install-packages.sh.tmpl`
- Branch on `.chezmoi.osRelease.id` (ubuntu/debian/fedora/arch) and
  `.idLike`, then call `apt-get`/`dnf`/`pacman`
- Long-term: install Homebrew on Linux + share a CLI-only Brewfile

### [ ] Split Brewfile into common / darwin / work
**Why:** `dot_Brewfile` mixes CLI tools (portable) with macOS casks. Hard to
share with Linux/WSL Homebrew.
**Approach:**
- `dot_Brewfile_common` — bat, fzf, ripgrep, fd, jq, etc.
- `dot_Brewfile_darwin` — casks + iOS/cocoapods/duti
- `dot_Brewfile_work.tmpl` gated on `.isWork`
- Update darwin install script to bundle all three

### [ ] Branch `SSH_AUTH_SOCK` per-platform in fish config
**File:** `dot_config/private_fish/config.fish.tmpl:46-47`
**Why:** Currently `SSH_AUTH_SOCK = ~/.1password/agent.sock` is darwin-only.
1Password Linux uses the same socket path; WSL needs npiperelay forwarding
from Windows.
**Approach:** add `else if .isWSL` (npiperelay) and `else if linux`
(keep same path).

### [ ] Wire `.isWork` into gitconfig email
**File:** `dot_gitconfig.tmpl:3`
**Why:** Right now `.email` is one value across all machines. Most people
want a different commit email on work hosts.
**Approach:** `promptStringOnce` for `workEmail` at init, then
`email = {{ if .isWork }}{{ .workEmail }}{{ else }}{{ .email }}{{ end }}`.

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

### [ ] Track `~/.profile`
**Why:** Currently has hardcoded `/Users/jason/bin` (should be `$HOME/bin`).
Sources cargo env. Useful on Linux/WSL too.
**Approach:** `dot_profile.tmpl`. Branch any platform-specific lines on
`.chezmoi.os`.

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

### [ ] Update README "History" / "License" placeholders
**File:** `README.md`
**Approach:** Either fill them in or remove the placeholder sections.
Currently say "TODO".

---

## Done (kept here briefly for context)

- ~~Hardcoded `x86_64` in chezmoi externals~~ — fixed in `7e40454`
- ~~Repeated `kernel.osrelease` / `hostname` checks~~ — `.isWSL`/`.isWork`
  centralized in `7e40454`
- ~~Hardcoded `/Users/jason` in gitconfig~~ — `.chezmoi.homeDir` in `7e40454`
- ~~Track `~/.ssh/config`~~ — added in `3cdf113`
- ~~macOS defaults script~~ — added in `3cdf113`
