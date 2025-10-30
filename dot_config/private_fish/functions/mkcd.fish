
function mkcd --description 'Create a directory and change into it'
    mkdir -p $argv
    cd $argv
end