#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/.dotfiles
############################

########## Variables
cd "$(dirname "$0")"
DOTFILES_DIR=~$(pwd -P)                     # dotfiles directory
olddir=~/.dotfiles_old                    # old dotfiles backup directory
links="vim bash git"                   # list of files/folders to symlink in homedir

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $dir directory"
cd $dir
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory
echo "Moving any existing dotfiles from ~ to $olddir"
shopt -s dotglob
for link in $links; do
   cd $link
   for file in *; do
      if [ -f $file ]; then
         echo "Moving ~/$file to $olddir"
         mv ~/$file $olddir
      fi
   done
   cd $DOTFILES_DIR
done

# use stow to create symlinks to files
for link in $links; do
   stow $link
done
