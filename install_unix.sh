#!/bin/bash
############################
# .make.sh
# This script creates symlinks from the home directory to any desired dotfiles in ~/.dotfiles
############################

############################
# Variables
############################
cd "$(dirname "$0")"
DOTFILES_DIR=$(pwd -P)                    # dotfiles directory
olddir=~/.dotfiles_old                    # old dotfiles backup directory
links="vim bash git tmux xterm dircolors"           # list of files/folders to symlink in homedir

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

# platform dependent links
if [[ $platform == 'cygwin' ]]; then
   links+=" mintty"
fi

# check if stow is installed before beginning
if stow --version &>/dev/null; then
   echo "Beginning dotfiles setup..."
else
   echo "stow utility not found, please install before beginning"
   exit 1
fi

# change to the dotfiles directory
echo "Changing to the $DOTFILES_DIR directory"
cd $DOTFILES_DIR
echo "...done"

############################
# Helper functions
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

      sed -e "s/AUTHORNAME/$git_authorname/g" -e "s/AUTHOREMAIL/$git_authoremail/g" .extras/.gitconfig.local.example > ~/.gitconfig.local

      success 'gitconfig'
   fi
}

backup_dotfiles () {
   if ! [ -d "$olddir" ]; then
      # create dotfiles_old in homedir
      echo "Creating $olddir/ for backup of any existing dotfiles in ~/"
      mkdir -p $olddir
      echo "...done"
   fi

   # move any existing dotfiles in homedir to dotfiles_old directory
   echo "Moving any existing dotfiles from ~/ to $olddir/"
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
}

restore_dotfiles () {
   echo "Moving old dotfiles from $olddir/ to ~/"
   shopt -s dotglob
   cd $olddir
   for file in *; do
      echo "Moving... $file"
      mv $file ~/
   done
}

create_symlinks () {
   # use stow to create symlinks to files
   for link in $links; do
      stow $link
   done
}

remove_symlinks () {
   # use stow to remove symlinks to files
   for link in $links; do
      stow -D $link
   done
}

update_vim_plugins () {
   # install vim plugins using vim-plug
   echo "Installing vim plugins..."
   vim +PlugUpdate +qall
}

install_menu () {
   PS3='Please enter your choice: '
   #options=("Install" "Update" "Uninstall" "Quit")
   select opt in "${options[@]}"
   do
      case $opt in
         "Install")
            backup_dotfiles
            setup_gitconfig
            create_symlinks
            update_vim_plugins
            break
            ;;
         "Update")
            remove_symlinks
            backup_dotfiles
            setup_gitconfig
            create_symlinks
            update_vim_plugins
            break
            ;;
         "Uninstall")
            remove_symlinks
            rm ~/.gitconfig.local
            restore_dotfiles
            rm -rf $olddir
            echo "Run rm -rf $DOTFILES_DIR to complete the uninstall"
            break
            ;;
         "Quit")
            break
            ;;
         *) echo invalid option;;
      esac
   done
}

new_install_menu () {
   cmd=(whiptail --separate-output --title "Dotfiles Installer" --checklist "Select Configurations:" 22 76 16)
   options=(1 "git" on 
   2 "tmux" on
   3 "mintty" off
   4 "vim" on
   5 "bash" on
   6 "dircolors" on
   7 "xterm" off)
   choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
   for choice in $choices
      do
      case $choice in
         1)
            echo "git"
            ;;
         2)
            echo "tmux"
            ;;
         3)
            echo "mintty"
            ;;
         4) 
            echo "vim"
            ;;
         5)
            echo "bash"
            ;;
         6)
            echo "dircolors"
            ;;
         7)
            echo "xterm"
            ;;
         *)
            echo "catch"
            ;;
      esac
   done
}

############################
# Main script
############################
new_install_menu
