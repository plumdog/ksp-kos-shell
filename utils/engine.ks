declare function seconds_for_dv {
    declare parameter required_dv.

    if required_dv > dv_in_stage() {
        return false.
    }

    set best_engine to stage_best_engine().
    // dv = 9.82 * isp * ln(mass / (mass - fuel_mass))
    // so
    // exp(dv / (9.82 * isp)) = mass / (mass - fuel_mass)
    // so
    // exp(-dv / (9.82 * isp)) = (mass - fuel_mass) / mass
    // so
    // fuel_mass = mass * (1 - exp(-dv / (9.82 * isp))
    set fuel_mass_required to ship:mass * (1 - constant:e ^ (-required_dv / (9.82 * best_engine:isp))).
    // fuel_burnt = thrust / (isp * 9.82) * seconds.
    return fuel_mass_required * (best_engine:isp * 9.82) / best_engine:availablethrust.
}

declare function stage_fuel_mass {
    // Assumes engine uses lf+ox in the ratio of 9 lf to 11 ox

    set lf to stage:resourceslex["liquidfuel"]:amount.
    set ox to stage:resourceslex["oxidizer"]:amount.

    set lf_density to 0.005.
    set ox_density to 0.005.

    if 11 * lf > 9 * ox {
        // too much lf
        set usable_lf to 9 * ox / 11.
        set lf to usable_lf.
    } else {
        set usable_ox to 11 * lf / 9.
        set ox to usable_ox.
    }

    return (ox * ox_density) + (lf * lf_density).
}

declare function stage_best_engine {
    set best_active_isp to 0.
    set best_active_engine to false.
    list engines in myengines.
    for eng in myengines {
        if eng:ignition and eng:isp > best_active_isp {
            set best_active_isp to eng:isp.
            set best_active_engine to eng.
        }
    }
    return best_active_engine.
}

declare function dv_in_stage {
    set fuel_mass to stage_fuel_mass().
    set best_engine to stage_best_engine().

    return 9.82 * best_engine:isp * ln(ship:mass / (ship:mass - fuel_mass)).
}
