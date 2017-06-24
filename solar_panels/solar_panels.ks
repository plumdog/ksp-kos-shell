local panel_extend_event is "extend solar panel".
local panel_retract_event is "retract solar panel".

declare local function _all_panel_modules {
    declare parameter ves.
    local panel_modules is list().
    local module_name is "ModuleDeployableSolarPanel".

    for part in ves:parts {
        if part:modules:contains(module_name) {
            local module is part:getmodule(module_name).

            if _can_extend_panel(module) or _can_retract_panel(module) {
                panel_modules:add(module).
            }
        }
    }

    return panel_modules.
}

declare local function _can_extend_panel {
    declare parameter panel_module.
    return panel_module:alleventnames:contains(panel_extend_event).
}

declare local function _can_retract_panel {
    declare parameter panel_module.
    return panel_module:alleventnames:contains(panel_retract_event).
}

declare local function _extend_panel {
    declare parameter panel_module.
    if _can_extend_panel(panel_module) {
        panel_module:doevent(panel_extend_event).
    }
}

declare local function _retract_panel {
    declare parameter panel_module.
    if _can_retract_panel(panel_module) {
        panel_module:doevent(panel_retract_event).
    }
}

declare function panels_extend_all {
    declare parameter ves is ship.
    for module in _all_panel_modules(ves) {
        _extend_panel(module).
    }
}

declare function panels_retract_all {
    declare parameter ves is ship.
    for module in _all_panel_modules(ves) {
        _retract_panel(module).
    }
}
