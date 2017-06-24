runpath("0:/utils/locks.ks").

declare function safe_orient {
    declare parameter dir is ship:prograde, seconds_limit is 100, accuracy is 1.
    set dir to R(dir:pitch, dir:yaw, ship:facing:roll).

    local limit_time is time:seconds + seconds_limit.

    lock_all().

    set steer to dir.

    wait until _good_enough(dir, accuracy) or (time:seconds > limit_time).
    return _good_enough(dir, accuracy).
}

declare local function _good_enough {
    declare parameter dir, accuracy.
    return (_angle_off(dir) < accuracy) and (_angular_velocity() < (accuracy / 10)).
}

declare local function _angle_off {
    declare parameter dir.
    return abs(vang(ship:facing:vector, dir:vector)).
}

declare local function _angular_velocity {
    return ship:angularvel:mag.
}
