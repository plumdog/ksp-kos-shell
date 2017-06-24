declare function orbital_velocity_at_altitude {
    declare parameter at_altitude, pe is orbit:periapsis, ap is orbit:apoapsis, bdy is body.

    set sma to (pe + ap) / 2 + bdy:radius.
    set two_over_r to 2 / (at_altitude + bdy:radius).
    set one_over_a to 1 / sma.
    return SQRT(bdy:mu * (two_over_r - one_over_a)).
}