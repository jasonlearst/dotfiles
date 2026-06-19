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
abbr -a grhs git reset --soft
abbr -a grs git restore
abbr -a grss git restore --staged
abbr -a gclean git clean -fd
abbr -a gpristine "git reset --hard && git clean -dffx"

# more log views
abbr -a glo git log --oneline --decorate
abbr -a glols git log --oneline --decorate --graph --stat
abbr -a glp git log -p
abbr -a gsh git show
abbr -a gwch git log --raw --no-merges
abbr -a gcount git shortlog --summary --numbered
abbr -a gbl git blame -w

# more diff views
abbr -a gdca git diff --cached
abbr -a gdw git diff --word-diff
abbr -a gdt git diff-tree --no-commit-id --name-only -r

# commit extras
abbr -a gcmsg --set-cursor "git commit -m \"%\""
abbr -a gfu --set-cursor "git commit --fixup %"
abbr -a gsq --set-cursor "git commit --squash %"

# rebase extras
abbr -a grbs git rebase --skip

# push extras
abbr -a gpd git push --dry-run
abbr -a gpt git push --tags

# stash extras
abbr -a gstaa git stash apply
abbr -a gstd git stash drop
abbr -a gstc git stash clear
abbr -a gsts git stash show --text

# remotes
abbr -a gr git remote
abbr -a grv git remote -v
abbr -a gra git remote add
abbr -a gru git remote update

# tags
abbr -a gt git tag
abbr -a gtv "git tag | sort -V"

# revert
abbr -a grev git revert

# worktree
abbr -a gwt git worktree
abbr -a gwta git worktree add
abbr -a gwtls git worktree list
abbr -a gwtrm git worktree remove

# bisect
abbr -a gbs git bisect
abbr -a gbss git bisect start
abbr -a gbsg git bisect good
abbr -a gbsb git bisect bad
abbr -a gbsr git bisect reset

# --- default-branch–aware helpers (functions: they compute main vs master) ---
function git_main_branch --description 'Echo the repo default branch (main/master/trunk)'
    command git rev-parse --git-dir >/dev/null 2>&1; or return
    for b in main trunk master
        if command git show-ref -q --verify refs/heads/$b
            echo $b
            return
        end
    end
    echo main
end

function gcom --description 'Checkout the default branch'
    git checkout (git_main_branch) $argv
end

function gmom --description 'Merge origin/<default branch>'
    git merge origin/(git_main_branch) $argv
end

function grbom --description 'Rebase onto origin/<default branch>'
    git rebase origin/(git_main_branch) $argv
end

function gpsup --description 'Push the current branch and set upstream'
    git push --set-upstream origin (git rev-parse --abbrev-ref HEAD) $argv
end

function gbda --description 'Delete local branches already merged into the default branch'
    set -l main (git_main_branch)
    for b in (git branch --format='%(refname:short)' --merged $main)
        test "$b" = "$main"; and continue
        git branch -d $b
    end
end
