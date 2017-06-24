@LAZYGLOBAL OFF.

runpath("0:/utils/linear.ks").
runpath("0:/utils/print.ks").
// runpath("0:/utils/engine.ks").
// runpath("0:/utils/orbit.ks").
runpath("0:/circularise/circularise.ks").


declare function runlaunch {

    local targetorbit is 80000.
    local style is "sleek".

    print_section("Overview").
    print_info("Ascending to circular orbit at " + targetorbit + "m").
    print_info("Using ascent style: " + style).

    local atmospherealtitude is BODY:ATM:HEIGHT.

    local throt is 1.0.
    LOCK THROTTLE to throt.

    print_section("Countdown").
    FROM {local countdown is 3.} UNTIL countdown = 0 STEP {set countdown to countdown - 1.} DO {
        print_info(countdown + "...").
        WAIT 1.
    }

    LOCK STEERING TO UP.

    print_info("Liftoff").

    WHEN MAXTHRUST = 0 THEN {
        STAGE.
        wait 1.
        PRESERVE.
    }

    local mysteer is UP + R(0, 0, -180).
    LOCK steering TO mysteer.

    local deg is 0.
    local max_alt_k is 0.
    local myvel is 0.
    local myalt is 0.
    local ascent is 0.
    local newthrot is 0.
    local max_alt_k is 0.

    print_section("Initial Ascent").
    UNTIL ship:apoapsis > targetorbit {

        set myvel to ship:velocity:surface:mag.
        set myalt to ship:altitude.

        set ascent to idealascent(myvel, myalt, style).

        set deg to ascent[0].
        set newthrot to ascent[1].

        if myalt > (max_alt_k + 1) * 1000 {
            set max_alt_k to round(myalt / 1000).
            if (max_alt_k <= 10) or (mod(max_alt_k, 10) = 0) {
                print_info("Passing " + max_alt_k + ",000m, pitch " + round(deg, 2) + ", throttle " + round(newthrot, 2)).
            }
        }

        set mysteer to UP + R(0, -deg, -180).
        set throt to newthrot.
    }

    WAIT UNTIL ship:apoapsis > targetorbit.
    set throt to 0.0.

    print_info("Powered ascent completed").

    unlock steering.
    SAS on.
    wait 1.
    set SASMODE to "PROGRADE".

    local boosting is false.
    local boosted is false.
    WHEN ship:altitude > atmospherealtitude THEN {
        print_section("Out of Atmosphere").
        if ship:apoapsis < targetorbit {
            set throt to 1.0.
            set boosting to true.
        } else {
            set boosted to true.
        }
    }

    WHEN ship:apoapsis > targetorbit THEN {
        if boosting {
            set throt to 0.0.
            set boosted to true.
        } else {
            preserve.
        }
    }

    WAIT UNTIL boosted.
    print_info("Apoapsis OK").

    set throt to 0.0.
    unlock throttle.
    wait 1.

    SAS off.

    circularise().

    print_alert("Completed, all OK").

    SAS ON.
}


declare local function idealascent {
    declare parameter myvel, myalt, style.

    return list(idealpitch(myvel, myalt, style), idealthrottle(myvel, myalt)).
}

declare local function idealpitch {
    declare parameter myvel, myalt, style.

    local lowfactor is 1.
    local midfactor is 1.
    local highfactor is 1.

    if style = "power" {
        set lowfactor to 3.
        set midfactor to 1.5.
        set highfactor to 1.0.
    } else if style = "sleek" {
        set lowfactor to 1.
        set midfactor to 0.8.
        set highfactor to 0.8.
    }

    local points is list(
        list(0, 0),
        list(100, 0),
        list(1000 * lowfactor, 5),
        list(12000 * midfactor, 45),
        list(60000 * highfactor, 90),
        list(70000, 90)).
    return multilinear(myalt, points).
}

declare local function idealthrottle {
    declare parameter myvel, myalt.

    local ideal is idealvelocity(myvel, myalt).

    if ideal > myvel {
        return 1.0.
    } else {
        // to ideal is less than current velocity. Throttle back proportional to overspeed.
        return 1.0 - (10 * (myvel - ideal) / ideal).
    }
}

declare local function idealvelocity {

    declare parameter myvel, myalt.

    if myalt <= 0 {
        return 100.
    } else if myalt <= 1000 {
        return linear(myalt, 0, 100, 1000, 150).
    } else if myalt <= 20000 {
        return linear(myalt, 1000, 150, 20000, 800).
    } else {
        return linear(myalt, 20000, 800, 100000, 3000).
    }
}
