runpath("0:/orient/orient.ks").
runpath("0:/utils/engine.ks").
runpath("0:/utils/locks.ks").
runpath("0:/utils/linear.ks").

// Halt the orbit, then drop straight down to the surface, slowing to a nice,
// soft landing.
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

    declare local function _done {
        return ship:status = "landed".
    }

    // want to ensure that the impact time is half of the time to burn to counter the impact velocity.
    local descent_throt_pid is pidloop(1.5, 0, 0).
    set descent_throt_pid:setpoint to 0.0.
    local fear_factor is 1.
    local comparison is 0.

    until _done() {
        set imp to impact_time() - time:seconds.

        if imp < 20 {
            set gear to true.
        }

        set dv to impact_dv().
        set dv_time to seconds_for_dv(dv).
        set descent_throt_pid:setpoint to dv_time.

        // Be less aggressive as we get close to the surface.
        if alt:radar < 20 {
            set fear_factor to 0.1.
        } else if alt:radar < 100 {
            set fear_factor to linear(alt:radar, 20, 0.1, 100, 1.0).
        } else {
            set fear_factor to 1.0.
        }

        if dv_time = false {
            // do nothing
        } else {
            // high throttle if low, low throttle if high
            set comparison to (imp * fear_factor - dv_time).
            set throt to descent_throt_pid:update(time:seconds, comparison).
        }
    }

    set throt to 0.0.

    lock_all().
}

// For the given vessel and absolute time, find the predicted altitude above the
// current body's 0-altitude.
declare function altitudeat {
    declare parameter ves, at_time.
    return (positionat(ves, at_time) - ves:body:position):mag - ves:body:radius.
}

// For the given vessel and absolute time, find the predicted altitude above
// terrain.
declare function geoaltitudeat {
    declare parameter ves, at_time.
    local actual_position is positionat(ves, at_time) - ves:body:position.
    local height is ves:body:geopositionof(actual_position):terrainheight.
    return actual_position:mag - height - ves:body:radius.
}

// Find the predicted impact speed.
declare function impact_dv {
    declare parameter ves is ship.
    local impact_t is impact_time(ves).
    return velocityat(ves, impact_t):surface:mag.
}

// Find the predicted absolute time of impact.
declare function impact_time {
    declare parameter ves is ship.

    if ves:orbit:periapsis > 0 {
        return false.
    }

    local terrainheight is alt:radar.
    if terrainheight < 1000 {
        // Just emulate as if the surface were flat.
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
