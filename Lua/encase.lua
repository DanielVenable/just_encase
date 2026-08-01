--[[
Encase Mod by Daniel

Made for the competition "Just In Case".

Note: I recommend you play the pack before trying to figure out what this does.
]]

local ENCASE_KEY = "E"
local ENCASE_MODE_UNDO = "toggle_encase_mode"

-- The unitids of any currently encased objects
local encased_units = {}
local is_encase_mode_on = false

table.insert(mod_hook_functions.keyboard_input, function(key)
    if editor.strings[MENU] == "ingame" and key[1] == ENCASE_KEY then
        if is_encase_mode_on then
            is_encase_mode_on = false
            print("disable encase")
        else
            is_encase_mode_on = true
            print("enable encase")
        end
        addundo({ ENCASE_MODE_UNDO, is_encase_mode_on })
        command("idle", 1)
    end
end)

table.insert(mod_hook_functions.level_start, function()
    is_encase_mode_on = false
    encased_units = {}
end)

undo_list[ENCASE_MODE_UNDO] = function(id, data)
    print("undid past encase", data[2])
    is_encase_mode_on = not data[2]
end