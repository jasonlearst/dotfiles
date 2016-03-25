#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/.dotfiles
############################

############################
# Helper functions
# https://github.com/holman/dotfiles/
############################
info () {
   printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}

user () {
   printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}

success () {
   printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}

fail () {
   printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
   echo ''
   exit
}

setup_gitconfig () {
   if ! [ -f ~/.gitconfig.local ]
   then
      info 'setup gitconfig'

      user ' - What is your github author name?'
      read -e git_authorname
      user ' - What is your github author email?'
      read -e git_authoremail

      sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" extras/.gitconfig.local.example > ~/.gitconfig.local

      success 'gitconfig'
   fi
}

############################
# Main script
############################
# check the platfrom
platform='unknown'
unamestr=$(uname)
if [[ "$unamestr" == "FreeBSD" ]]; then
   platform='freebsd'
elif [[ "$unamestr" == "Darwin"* ]]; then
   platform='osx'
elif [[ "$unamestr" == "Linux" ]]; then
   platform='linux'
elif [[ "$unamestr" == "CYGWIN"* ]]; then
   platform='cygwin'
fi

# check if stow is installed before beginning
if stow --version &>/dev/null; then
   echo "Beginning dotfiles setup..."
else
   echo "stow utility not found, please install before beginning"
   exit 1
fi

########## Variables
cd "$(dirname "$0")"
DOTFILES_DIR=$(pwd -P)                     # dotfiles directory
olddir=~/.dotfiles_old                    # old dotfiles backup directory
links="vim bash git tmux"                   # list of files/folders to symlink in homedir

# platform dependent links
if [[ $platform == 'cygwin' ]]; then
   links+=" mintty"
fi

##########

# create dotfiles_old in homedir
echo "Creating $olddir for backup of any existing dotfiles in ~"
mkdir -p $olddir
echo "...done"

# change to the dotfiles directory
echo "Changing to the $DOTFILES_DIR directory"
cd $DOTFILES_DIR
echo "...done"

# move any existing dotfiles in homedir to dotfiles_old directory
echo "Moving any existing dotfiles from ~ to $olddir"
shopt -s dotglob
for link in $links; do
   cd $link
   for file in *; do
      if [ -f ~/$file ]; then
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

# Run local gitconfig setup
setup_gitconfig

# install vim plugins using vim-plug
echo "Installing vim plugins..."
vim +PlugInstall +qall
