# ~/.config/fish/conf.d/ls_aliases.fish

function _ls_wrapper --description 'Wrapper for eza/lsd/ls'
    if command -q eza
        command eza --color=always --group-directories-first --icons $argv
    else if command -q lsd
        command lsd $argv
    else
        command ls $argv
    end
end

function l --description 'List directory contents with details'
    _ls_wrapper -l $argv
end

function la --description 'List all including hidden'
    _ls_wrapper -a $argv
end

function lla --description 'List all with details'
    _ls_wrapper -la $argv
end

function ll --description 'List with details'
    _ls_wrapper -l $argv
end

function ls --description 'List directory contents'
    _ls_wrapper $argv
end

function lt --description 'Show tree of directory contents'
    _ls_wrapper --tree $argv
end

function l. --description 'Show only dotfiles'
    _ls_wrapper -a | grep -e '^\.'
end