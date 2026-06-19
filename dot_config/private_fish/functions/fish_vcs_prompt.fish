function fish_vcs_prompt --description 'Print jj/git vcs prompt'
    # Only jj and git are used here. The stock fish_vcs_prompt also tries
    # fish_hg_prompt and fish_fossil_prompt, but with hg/fossil not installed
    # each call forces a full $PATH scan for the missing binary. On WSL that is
    # slow because $PATH includes Windows dirs under /mnt reached over the 9p
    # bridge, adding ~100-500ms to every prompt. jj/git are found early so they
    # stay fast.
    fish_jj_prompt $argv
    or fish_git_prompt $argv
end
