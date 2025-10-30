function tempe --description 'Create a temporary directory and change into it'
    cd (mktemp -d)
    chmod -R 0700 .
    if test (count $argv) -eq 1
        mkdir -p $argv[1]
        cd $argv[1]
        chmod -R 0700 .
    end
end
