@LAZYGLOBAL OFF.

runpath("0:/utils/linear.ks").
runpath("0:/utils/print.ks").
runpath("0:/utils/engine.ks").
runpath("0:/utils/orbit.ks").
runpath("0:/utils/locks.ks").
runpath("0:/orient/orient.ks").


// Circularise at either apoapsis or periapsis.
declare function circularise {
    declare parameter is_ap is true.

    local target_point is orbit:apoapsis.
    if not is_ap {
        set target_point to orbit:periapsis.
    }

    SAS off.
    lock_all().

    declare parameter autostage is true.
    declare parameter declare_section is true.

    if declare_section {
        print_section("Circularisation").
    }

    local targetvelocity is orbital_velocity_at_altitude(target_point, target_point, target_point).
    local expected_velocity is orbital_velocity_at_altitude(target_point).



    local dv is targetvelocity - expected_velocity.

    local retro is (dv < 0).
    set dv to abs(dv).

    print_info("Required delta-v: " + round(dv, 2) + "m/s").

    local initial_dv is dv_in_stage().

    if initial_dv < (1.1 * dv) {
        if autostage {
            // Insufficient dv in current stage.

            print_info("Insufficient dv in current stage.").
            print_info("Staging to find more dv.").

            // TODO: write a stage_until_thrust() method.
            wait 1.
            stage.
            wait 1.

            return circularise(false, false).
        } else {
            print_abort("Need to stage to find enough delta-v for burn, but not permitted").
            return false.
        }
    }

    local approx_burn_time is seconds_for_dv(dv).
    print_info("Approx burn time: " + round(approx_burn_time, 2) + "s").

    local wait_time is (_eta_point(is_ap) - (approx_burn_time / 1.8)).
    local wait_epoch is time:seconds + wait_time.

    // try to point in roughly the right direction before time-warping.
    print_info("Performing early orientation").
    local future_direction is velocityat(ship, time + wait_time):orbit:direction.

    if retro {
        set future_direction to (-future_direction:vector):direction.
    }

    local orient_ok is safe_orient(
        future_direction,
        wait_time).

    if not orient_ok {
        print_abort("Unable to orient correctly before burn").
        return false.
    }

    sas on.

    if wait_time > 20 {
        print_info("Warping to burn start").
        kuniverse:timewarp:warpto(wait_epoch - 15).
    }

    sas off.

    WAIT until time:seconds > (wait_epoch - 14).
    unlock steering.
    if retro {
        lock steering to ship:retrograde.
    } else {
        lock steering to ship:prograde.
    }

    WAIT 14.

    print_info("Burning to circularise at approx " + round(target_point) + "m").

    set throt to 1.0.

    declare local function _success {
        parameter target_point, retro.

        if retro {
            return ship:apoapsis < target_point.
        } else {
            return ship:periapsis > target_point.
        }
    }

    until _success(target_point, retro) {
        local approx_dv_remaining is abs(targetvelocity - ship:velocity:orbit:mag).
        local approx_burn_time_remaining is approx_dv_remaining / (ship:availablethrust / ship:mass).
        if _eta_point(is_ap) < 0 {
            set throt to 1.0.
        } else {
            set throt to linear(_eta_point(is_ap), approx_burn_time_remaining, 1.0, approx_burn_time_remaining * 2 + 1, 0.0).
        }
    }

    wait until _success(target_point, retro).
    set throt to 0.0.

    lock_all().

    local used_dv is initial_dv - dv_in_stage().
    print_info("Used " + round(used_dv, 2) + "m/s of dv, " + round(100.0 * used_dv / dv, 2) + "% of optimal").

    return true.
}

declare local function _eta_point {
    declare parameter is_ap.
    if is_ap {
        return eta:apoapsis.
    } else {
        return eta:periapsis.
    }
}
