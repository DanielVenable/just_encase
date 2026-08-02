--[[
Encase Mod by Daniel

Made for the competition "Just In Case".

Note: I recommend you play the pack before trying to figure out what this does.
]]

-- Constants:
local ENCASE_KEY = "E"
local ENCASE_MODE_UNDO = "toggle_encase_mode"
local BORDER_OBJECT = "line"
local INNER_OBJECT = "ice"

-- Mutables:
local encased_unitids = {}
local is_encase_mode_on = false

table.insert(mod_hook_functions.keyboard_input, function(key)
    if editor.strings[MENU] == "ingame" and key[1] == ENCASE_KEY then
        if is_encase_mode_on then
            is_encase_mode_on = false

            -- Deleting mutates the array, so we need to copy it first
            local to_delete = {}
            for k, v in ipairs(unitlists[BORDER_OBJECT]) do
                to_delete[k] = v
            end

            for _, border in ipairs(to_delete) do
                MF_specialremove(border, 2)
                delete(border)
            end
        else
            is_encase_mode_on = true
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
    is_encase_mode_on = not data[2]
end
