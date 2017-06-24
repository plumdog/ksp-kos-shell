runpath("0:/orient/orient.ks").

runpath("0:/utils/console_select.ks").
runpath("0:/utils/print.ks").
runpath("0:/utils/string.ks").
runpath("0:/utils/errors.ks").

local orient_prograde is "prograde".
local orient_retrograde is "retrograde".

local orient_options is list(
    orient_prograde,
    orient_retrograde
).

declare local function option_to_dir {
    declare parameter option.
    if option = orient_prograde {
        return ship:prograde.
    } else if option = orient_retrograde {
        return ship:retrograde.
    }
    fatal_error("Invalid option selected: " + option).
}

declare function runorient {
    local options is lexicon().
    for opt in orient_options {
        options:add(opt, titlecase(opt)).
    }
    local selected to select(options).

    if selected = false {
        return.
    }

    local start is time:seconds.
    safe_orient(option_to_dir(selected)).
    local end is time:seconds.
    print_info("Time taken: " + round(end - start, 2) + "s").
}

runorient().
