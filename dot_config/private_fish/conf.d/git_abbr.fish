# ~/.config/fish/conf.d/git_abbr.fish
#
# Popular git shortcuts, modelled on oh-my-zsh's git plugin.
# Implemented as abbreviations so they expand inline before running: you see
# (and store in history) the real `git …` command, and `git` tab-completion
# keeps working. Edit/remove any line and re-run `chezmoi apply`.

abbr -a g git

# status
abbr -a gst git status
abbr -a gss git status -s

# add
abbr -a ga git add
abbr -a gaa git add --all
abbr -a gap git add --patch

# commit
abbr -a gc git commit -v
abbr -a gca git commit -v --amend
abbr -a gcan git commit -v --amend --no-edit
abbr -a gcm --set-cursor "git commit -m \"%\""
abbr -a gcam --set-cursor "git commit -a -m \"%\""

# checkout / switch
abbr -a gco git checkout
abbr -a gcb git checkout -b
abbr -a gsw git switch
abbr -a gswc git switch -c

# branch
abbr -a gb git branch
abbr -a gba git branch -a
abbr -a gbd git branch -d
abbr -a gbD git branch -D

# diff
abbr -a gd git diff
abbr -a gds git diff --staged

# push / pull / fetch
abbr -a gp git push
abbr -a gpf git push --force-with-lease
abbr -a gpu git push -u origin HEAD
abbr -a gl git pull
abbr -a glr git pull --rebase
abbr -a gf git fetch
abbr -a gfa git fetch --all --prune

# log
abbr -a glog git log --oneline --decorate --graph
abbr -a gloga git log --oneline --decorate --graph --all

# rebase
abbr -a grb git rebase
abbr -a grbi git rebase -i
abbr -a grbc git rebase --continue
abbr -a grba git rebase --abort

# merge / cherry-pick
abbr -a gm git merge
abbr -a gcp git cherry-pick

# stash
abbr -a gsta git stash push
abbr -a gstp git stash pop
abbr -a gstl git stash list

# reset / restore / clean
abbr -a grh git reset
abbr -a grhh git reset --hard
abbr -a grs git restore
abbr -a grss git restore --staged
abbr -a gclean git clean -fd
