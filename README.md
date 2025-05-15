# dotfiles

These are my personal dotfiles.  I use these over multiple platforms and machines.

## Installation

The below command installs chezmoi and initilizes the dotfiles.  See: [chezmoi One-line binary install](https://www.chezmoi.io/install/#one-line-binary-install) for more information.

`sh -c "$(curl -fsLS get.chezmoi.io/lb)" -- init --apply git@github.com:jasonlearst/dotfiles.git`

Run `tmux` and install plugins with `prefix + I` (capital i, as in in Install)
Run `nvim` and install plugins with `:Lazy sync`
Run `vim` and install plugins with `:PlugInstall`

## Usage

Use the dotfiles!

## Contributing

If you have any ideas for improvement feel free to contribute!

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## History

TODO: Write history

## Credits

[http://dotfiles.github.io/](http://dotfiles.github.io/)  
[chezmoi Dotfiles Manager](https://www.chezmoi.io/)

## License

TODO: Write license
