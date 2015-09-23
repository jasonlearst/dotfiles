""""""""""""""""""""""""""""
"" install_win.bat
"" This script creates symlinks from the home directory to and desired dotfiles in ~/dotfiles
""""""""""""""""""""""""""""

"""""""" Variables

set dir=%USERPROFILE%\dotfiles                             "" dotfiles directory
set olddirr=%USERPROFILE%\dotfiles_old                     "" old dotfiles backup directory
set files="vimrrc vim"                                     "" list of files/folders to symlink in homedirr

""""""""""

"" create dotfiles_old in homedir
echo "Creating %olddir% for backup of any existing dotfiles in ~/"
mkdir -p %olddir%
echo "..done"
