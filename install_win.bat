@echo off

REM """"""""""""""""""""""""""""
REM  install_win.bat
REM  This script creates symlinks from the home directory to and desired dotfiles in ~/dotfiles
REM """"""""""""""""""""""""""""

REM """""""" Variables

set dir=%USERPROFILE%\.dotfiles
set olddir=%USERPROFILE%\.dotfiles_old
set files=(.vimrc .vim)

REM """"""""""

REM  create dotfiles_old in homedir
echo "Creating %olddir% for backup of any existing dotfiles in ~/"
mkdir %olddir%
echo "..done"

REM  change to the dotfiles directory
echo "Changing to the %dir% directory"
cd %dir%
echo "...done"

REM  move any existing dotfiles in homedir to dotfiles_old directory, then create symlinks
echo "Moving any existing dotfiles from ~/ to %olddir%"
for %%x in %files% do (
      move %USERPROFILE%\%%x %olddir%\
      )
cd vim
REM symlinks for files
for %%x in (*) do (
      for %%y in %files% do (
         if %%y == %%x (
            echo "Creating symlink to %%x in home directory."
            mklink /H %USERPROFILE%\%%x %dir%\vim\%%x
            )
         )
      )
REM symlinks for directories
for /D %%x in (*) do (
      for %%y in %files% do (
         if %%y == %%x (
            echo "Creating symlink to %%x in home directory."
            mklink /J %USERPROFILE%\%%x %dir%\vim\%%x
            )
         )
      )
