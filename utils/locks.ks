runpath("0:/utils/errors.ks").

// Some functions to try to keep the globals inline and locked as expected.
declare local function _globals_defined_ok {
    return (defined throt and defined steer).
}

declare function lock_all {
    if not _globals_defined_ok() {
        fatal_error("Globals for locks not defined").
    }
    unlock_all().
    lock steering to steer.
    lock throttle to throt.
}

declare function unlock_all {
    unlock steering.
    unlock throttle.
}
