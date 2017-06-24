runpath("0:/circularise/circularise.ks").
runpath("0:/utils/console_select.ks").

local ap is "apoapsis".
local pe is "periapsis".

local options to lexicon(
    ap, "Apoapsis",
    pe, "Periapsis"
).

local selected to select(options).

print "selected: " + selected.

if selected = false {
    // nothing
} else {
    circularise(selected = ap).
}
