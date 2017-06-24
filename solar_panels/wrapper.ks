runpath("0:/solar_panels/solar_panels").
runpath("0:/utils/console_select.ks").

local options is lexicon(
    "extend", "Extend",
    "retract", "Retract"
).

local selected is select(options).

if selected = "extend" {
    panels_extend_all().
} else if selected = "retract" {
    panels_retract_all().
}
