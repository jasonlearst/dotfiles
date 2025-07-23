if command --query tere
    function tere
        set --local result (command tere $argv)
        [ -n "$result" ] && cd -- "$result"
    end
end