# dotfiles

These are my personal dotfiles.  I use these over multiple platforms and machines.

## Installation

On a Mac where you want the Brewfile's packages, install [Homebrew](https://brew.sh) first: chezmoi doesn't install it, and on Macs without it the apply skips the packages (and the Dock PATH below). Installing Homebrew later makes the next `chezmoi apply` catch up.

The below command installs chezmoi and initializes the dotfiles. See: [chezmoi One-line binary install](https://www.chezmoi.io/install/#one-line-binary-install) for more information.

```sh
sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply https://github.com/jasonlearst/dotfiles.git
```

Uses HTTPS so it works on machines that don't yet have a GitHub SSH key (e.g. a fresh remote server). To push from this machine later, switch the remote to SSH:

```sh
git -C ~/.local/share/chezmoi remote set-url origin git@github.com:jasonlearst/dotfiles.git
```

Run `tmux` and install plugins with `prefix + I` (capital i, as in in Install)
Run `nvim` and install plugins with `:Lazy sync`
Run `vim` and install plugins with `:PlugInstall`

On a personal Mac, `init` also asks for the AI agent's git name and email, and the apply sets up its identity in `~/.agent-identity` and runs `agent-setup`, which creates the machine's SSH key and lists the credentials still to create in a browser. Run `agent-setup` again until it reports nothing left; `~/.agent-identity/README.md` explains the rest.

On a personal Mac with Homebrew, the first apply also asks for your password once, to put Homebrew on the PATH of apps opened from the Dock (git hooks that Workbench or Fork run, like git-lfs's, need it). Restart the Mac afterwards. An apply that can't ask, with no terminal, says so and leaves it to the next apply.

## Usage

Use the dotfiles!

## Contributing

If you have any ideas for improvement feel free to contribute!

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Credits

[http://dotfiles.github.io/](http://dotfiles.github.io/)  
[chezmoi Dotfiles Manager](https://www.chezmoi.io/)

## License

MIT — see [LICENSE.txt](./LICENSE.txt).
