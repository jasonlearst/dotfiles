if [ -t 1 ]
then
   # standard output is a tty
   # do interactive initialization
   bind "set completion-ignore-case on"
   bind "set show-all-if-ambiguous on"
fi

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

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
   debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
   xterm-color|*-256color) color_prompt=yes;;
esac

# import git prompt
export GIT_PS1_SHOWDIRTYSTATE=yes
source /usr/lib/git-core/git-sh-prompt

if [ "$color_prompt" = yes ]; then
   PS1="${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$(__git_ps1)\[\033[00m\]$ "
else
   PS1="${debian_chroot:+($debian_chroot)}\u@\h:\w\$(__git_ps1)\$ "
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
   xterm*|rxvt*)
      PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
      ;;
   *)
      ;;
esac

###################
#### MY ALIASES ###
###################

if [[ $platform == 'linux' ]] || [[ $platform == 'cygwin' ]]; then
   alias ls='ls --color=auto'
   alias ll='ls --color=auto -Flash'
   alias la='ls --color=auto -A'
   alias l='ls --color=auto -FC'
else
   alias ls="ls -G"
   alias ll="ls -GFlash"
   alias la="ls -Ga"
fi

# git commamands simplified
alias gst='git status'
alias gco='git checkout'
alias gci='git commit'
alias grb='git rebase'
alias gbr='git branch'
alias gad='git add -A'
alias gpl='git pull'
alias gpu='git push'
alias glg='git log --date-order --all --graph --format="%C(green)%h%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'
alias glg2='git log --date-order --all --graph --name-status --format="%C(green)%H%Creset %C(yellow)%an%Creset %C(blue bold)%ar%Creset %C(red bold)%d%Creset%s"'

#mkdir and cd
mkdircd() { mkdir "$1" && cd "$1" ; }

# lock computer
alias lock='/System/Library/CoreServices/"Menu Extras"/User.menu/Contents/Resources/CGSession -suspend'

## hibernation and sleep settings
#alias hibernate='sudo pmset -a hibernatemode 25'
#alias sleep='sudo pmset -a hibernatemode 0'
#alias safesleep='sudo pmset -a hibernatemode 3'
#alias smartsleep='sudo pmset -a hibernatemode 2'

# up 'n' folders
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# simple ip
alias ip='ifconfig | grep "inet " | grep -v 127.0.0.1 | cut -d\ -f2'
# more details
alias ip1="ifconfig -a | perl -nle'/(\d+\.\d+\.\d+\.\d+)/ && print $1'"
# external ip
alias ip2="curl -s http://www.showmyip.com/simple/ | awk '{print $1}'"

# grep with color
alias grep='grep --color=auto'

# proxy tunnel
#alias proxy='ssh -D XXXX -p XXXX USER@DOMAIN'
# ssh home
#alias sshome='ssh -p XXXX USER@DOMAIN'

# processes
alias ps='ps -ax'

# refresh shell
alias reload='source ~/.bash_profile'

# add android dev tools to PATH
if [[ -z $TMUX ]]; then
   PATH="$HOME/Library/Android/sdk/platform-tools:/usr/local/sbin:$PATH"
fi

# set VISUAL variable for visudo and sudoedit
export VISUAL=vim
export EDITOR="vi -e"

[ -e ~/.dircolors ] && eval $(dircolors -b ~/.dircolors) || eval $(dircolors -b)
