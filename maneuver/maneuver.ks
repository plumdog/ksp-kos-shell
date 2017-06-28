runpath("0:/orient/orient.ks").
runpath("0:/utils/engine.ks").
runpath("0:/utils/print.ks").
runpath("0:/utils/locks.ks").

declare function run_node {
    // Fairly crude node execution script. Just waits until half-burn-time before
    // the node, and burn until half-burn-time after the node.
    print_section("Running maneuver for node").

    if not hasnode {
        print_abort("No node configured").
        return false.
    }

    local node is nextnode.

    local burn_time is seconds_for_dv(node:deltav:mag).
    if not burn_time {
        print_abort("Insufficient delta-v in stage").
        return false.
    }
    print_info("Approximate burn time: " + round(burn_time, 2) + "s").
    local seconds_to_burn_start is node:eta - (burn_time / 2).
    local burn_start_epoch is time:seconds + seconds_to_burn_start.

    local buffer_seconds is 10.

    if not safe_orient(node:burnvector:direction, seconds_to_burn_start - buffer_seconds) {
        print_abort("Unable to orient before burn start").
        return false.
    }

    if time:seconds < burn_start_epoch - buffer_seconds {
        print_info("Warping to burn start").
        kuniverse:timewarp:warpto(burn_start_epoch - buffer_seconds).
    }

    wait until time:seconds > burn_start_epoch - buffer_seconds.

    unlock steering.
    lock steering to node:deltav.

    print_info("Waiting for burn start").
    wait until time:seconds > burn_start_epoch.
    set throt to 1.0.
    wait until time:seconds > burn_start_epoch + burn_time.
    set throt to 0.0.

    print_info("Crude burn completed.").

    lock_all().
    return true.
}
