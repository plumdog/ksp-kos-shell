PRINT "Booting shell".

runpath("0:/utils/locks.ks").
runpath("0:/utils/path.ks").
runpath("0:/utils/string.ks").
runpath("0:/utils/print.ks").
runpath("0:/utils/console_select.ks").

// Some actual real life globals.
global throt is 0.0.
global steer is ship:facing.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

declare local function reset {
    sas off.
    SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

    set throt to 0.0.
    set steer to ship:facing.

    lock_all().
}

declare local function find_wrappers {
    local wrappers is lexicon().
    local trial_path is "".
    local nicename is "".

    for fpath in list_paths("0:/") {
        set trial_path to fpath + "/wrapper.ks".

        if exists(trial_path) {
            set nicename to basename(fpath).
            set nicename to nicename:replace("_", " ").
            set nicename to titlecase(nicename).

            wrappers:add(trial_path, nicename).
        }
    }
    return wrappers.
}

local exit is false.

until exit {
    local selected is select(find_wrappers()).

    if selected = false {
        print_alert("Exiting").
        set exit to true.
    } else {
        print "Running...".
        reset().
        runpath(selected).
        reset().
        unlock_all().
        print "All done".
        print "".

        wait 1.
    }
}

wait until exit.
