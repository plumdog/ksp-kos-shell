runpath("0:/orient/orient.ks").
runpath("0:/utils/engine.ks").
runpath("0:/utils/locks.ks").
runpath("0:/utils/linear.ks").

declare function stone {

    if ship:orbit:periapsis > 0 {
        safe_orient(ship:retrograde).

        local h_burn_time is seconds_for_dv(ship:velocity:orbit:mag).
        set throt to 1.0.
        wait h_burn_time.
        set throt to 0.0.
    }

    unlock steering.
    lock steering to srfretrograde.

    local imp is impact_time() - time:seconds.
    local dv is impact_dv().
    local dv_time is 0.

    print "Impact seconds: " + round(imp, 2) + "s".
    print "Impact dv: " + round(dv, 2) + "m/s".
    print "Burn time: " + round(dv_time, 2) + "s".

    local loop_count is 0.

    declare local function _done {
        declare parameter dv.
        // Stop when the impact would be slow, or we're super close to the ground, or we've started moving up again.
        return (dv < 2) or (alt:radar < 2).
    }

    // want to ensure that the impact time is half of the time to burn to counter the impact velocity.
    local descent_throt_pid is pidloop(0.1, 0, 0, 0.0, 1.0).

    until _done(dv) {
        set imp to impact_time() - time:seconds.

        if imp < 20 {
            set gear to true.
        }

        set dv to impact_dv().
        set dv_time to seconds_for_dv(dv).
        if dv_time = false {
            // do nothing
        } else {
            // high throttle if low, low throttle if high
            local comparison is (imp / 2 - dv_time).
            print "Comparison: " + round(comparison, 2) + "s".

            // set throt to throt + descent_throt_pid:update(time:seconds, comparison).
            if imp < 0.5 * dv_time {
                set throt to 1.0.
            } else if imp >= 4 * dv_time {
                set throt to 0.0.
            } else {
                // set throt to throt +
                set throt to multilinear(
                    imp,
                    list(
                        list(0, 1.0),
                        list(2 * dv_time, 1.0),
                        list(4 * dv_time, 0.0),
                        list(5 * dv_time, 0.0)
                    )
                ).
            }

            if loop_count = 0 {
                print "Impact seconds: " + round(imp, 2) + "s".
                print "Impact dv: " + round(dv, 2) + "m/s".
                print "Burn time: " + round(dv_time, 2) + "s".
                print "Throt: " + round(throt, 2).
                //local alt_my_guess is geoaltitudeat(ship, time:seconds).
                //local alt_real is alt:radar.
                //print "Terrain altitude error: " + round(alt_my_guess - alt_real, 2) + "m".
                //print "Guess: " + round(alt_my_guess, 2) + "m".
                //print "Real:  " + round(alt_real, 2) + "m".
            }
        }

        // set loop_count to mod(loop_count + 1, 10).
    }
    wait until _done(dv).
    set throt to 0.0.

    lock_all().
}

declare function altitudeat {
    declare parameter ves, at_time.
    return (positionat(ves, at_time) - ves:body:position):mag - ves:body:radius.
}

declare function geoaltitudeat {
    declare parameter ves, at_time.
    local actual_position is positionat(ves, at_time) - ves:body:position.
    local height is ves:body:geopositionof(actual_position):terrainheight.
    return actual_position:mag - height - ves:body:radius.
}

declare function impact_dv {
    declare parameter ves is ship.
    local impact_t is impact_time(ves).
    return velocityat(ves, impact_t):surface:mag.
}

declare function impact_time {
    declare parameter ves is ship.

    if ves:orbit:periapsis > 0 {
        return false.
    }

    local terrainheight is alt:radar.
    if terrainheight < 1000 {
        print "Terrain height: " + terrainheight + "m".
        local down_vel is -vdot(ship:velocity:surface, UP:vector).
        // s = ut + 0.5*at^2
        // at^2 + 2ut - 2s = 0
        // t = (-2u +/- sqrt(4u^2 + 4*a*2s)) / 2a
        //   = (-u +/- sqrt(u^2 + a*2s)) / a
        // definitely want positive root
        // t = (-u + sqrt(u^2 + 2as)) / a
        local accel is ves:body:mu / (ves:altitude + ves:body:radius) ^ 2.
        if abs(accel) < 0.001 {
            // s = ut
            if down_vel < 0.1 {
                print "Impact time inf - not moving downward".
                return 10 ^ 12.  // infinity. ish.
            } else {
                return time:seconds + (terrainheight / down_vel).
            }
        } else {
            local b_sq is down_vel * down_vel.
            local minus_two_ac is 2*accel*terrainheight.
            local sqrt_b_sq_minus_two_ac is sqrt(b_sq + minus_two_ac).
            return time:seconds + ((-down_vel + sqrt_b_sq_minus_two_ac) / accel).
        }
    }

    local now is time:seconds.
    local eta_pe is eta:periapsis.
    local eta_ap is eta:apoapsis.

    local maxits is 20.
    local abovetime is now.
    if eta:apoapsis < eta:periapsis {
        set abovetime to now + eta_ap.
    }
    local belowtime is now + eta_pe.
    local midtime is 0.

    local belowalt is 0.
    local abovealt is 0.
    local midalt is 0.

    for it in range(10) {
        set belowalt to geoaltitudeat(ves, belowtime).
        set abovealt to geoaltitudeat(ves, abovetime).

        set midtime to (abovetime + belowtime) / 2.

        if abs(abovealt - belowalt) < 1 {
            break.
        }

        set midalt to geoaltitudeat(ves, midtime).

        if midalt < 0 {
            set belowtime to midtime.
        } else {
            set abovetime to midtime.
        }
    }

    return midtime.
}
