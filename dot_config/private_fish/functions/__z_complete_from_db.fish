# zoxide completes `z foo<Tab>` from local folders only, like cd. This adds the
# folders in its database, so a partial name completes to one you've visited.
# `z foo<Space><Tab>` still opens zoxide's interactive picker.
function __z_complete_from_db
    set -l before (commandline --cut-at-cursor --current-process --tokenize)
    set -l token (commandline --current-token)
    test (count $before) -eq 1 -a -n "$token"; or return
    command zoxide query --list --exclude "$PWD" -- $token 2>/dev/null
end
