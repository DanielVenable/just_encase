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
local encased_ids = {}
local is_encase_mode_on = false

table.insert(mod_hook_functions.keyboard_input, function(key)
    if editor.strings[MENU] == "ingame" and key[1] == ENCASE_KEY then
        if is_encase_mode_on then
            exit_encase_mode()
        else
            enter_encase_mode()
        end
        command("idle", 1)
    end
end)

table.insert(mod_hook_functions.level_start, function()
    is_encase_mode_on = false
    encased_units = {}
end)

undo_list[ENCASE_MODE_UNDO] = function(_, data)
    is_encase_mode_on = not data[2]
    encased_ids = data[3]
end

table.insert(mod_hook_functions.block, function()
    if is_encase_mode_on then
        local encased_squares = find_all_encased_squares()
        if #encased_squares > 0 then
            exit_encase_mode()

            for _, square in ipairs(encased_squares) do
                local here = findallhere(square.x, square.y)
                if #here > 0 then
                    local _, id = create(INNER_OBJECT, square.x, square.y, 0)
                    table.insert(encased_ids, id)
                end
                for _, obj in ipairs(here) do
                    table.insert(encased_ids, mmf.newObject(obj).values[ID])
                end
            end
        else
            for _, you in ipairs(findallfeature(nil, "is", "you")) do
                local unit = mmf.newObject(you)
                create(BORDER_OBJECT, unit.values[XPOS], unit.values[YPOS], unit.values[DIR])
            end
        end
    end
end)

function find_all_encased_squares()
    local function pair(x, y)
        return tostring(x) .. "," .. tostring(y)
    end

    local function unpair(str)
        local pos = {}
        for a in string.gmatch(str, "([^,]+)") do
            table.insert(pos, a)
        end
        return tonumber(pos[1]), tonumber(pos[2])
    end

    local max_x, min_x = 0, 9999
    local max_y, min_y = 0, 9999
    local visited = {}
    local borders = unitlists[BORDER_OBJECT]

    if borders == nil then return {} end

    for _, border in ipairs(borders) do
        local unit = mmf.newObject(border)
        local x, y = unit.values[XPOS], unit.values[YPOS]
        max_x = math.max(max_x, x)
        max_y = math.max(max_y, y)
        min_x = math.min(min_x, x)
        min_y = math.min(min_y, y)
        visited[pair(x, y)] = true
    end

    local cur = {}
    local continue_loop = true

    for i = min_x, max_x do
        cur[pair(i, min_y)] = true
        cur[pair(i, max_y)] = true
    end

    for i = min_y, max_y do
        cur[pair(min_x, i)] = true
        cur[pair(max_x, i)] = true
    end

    while continue_loop do
        continue_loop = false
        local next = {}
        for k, _ in pairs(cur) do
            if not visited[k] then
                visited[k] = true
                continue_loop = true
                x, y = unpair(k)
                if min_x <= x and x <= max_x and min_y <= y and y <= max_y then
                    next[pair(x - 1, y - 1)] = true
                    next[pair(x - 1, y)] = true
                    next[pair(x - 1, y + 1)] = true
                    next[pair(x, y - 1)] = true
                    next[pair(x, y + 1)] = true
                    next[pair(x + 1, y - 1)] = true
                    next[pair(x + 1, y)] = true
                    next[pair(x + 1, y + 1)] = true
                end
            end
        end
        cur = next
    end

    local encased_squares = {}

    for x = min_x, max_x do
        for y = min_y, max_y do
            if not visited[pair(x, y)] then
                table.insert(encased_squares, { x = x, y = y })
            end
        end
    end

    return encased_squares
end

function enter_encase_mode()
    is_encase_mode_on = true
    delete_all(INNER_OBJECT)
    addundo({ ENCASE_MODE_UNDO, true, encased_ids })
    encased_ids = {}
end

function exit_encase_mode()
    is_encase_mode_on = false
    delete_all(BORDER_OBJECT)
    addundo({ ENCASE_MODE_UNDO, false, encased_ids })
    encased_ids = {}
end

function delete_all(obj_name)
     -- Deleting mutates the array, so we need to copy it first
    local to_delete = {}
    for k, v in ipairs(unitlists[obj_name] or {}) do
        to_delete[k] = v
    end

    for _, border in ipairs(to_delete) do
        delete(border)
    end
end
