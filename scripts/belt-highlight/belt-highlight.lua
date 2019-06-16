local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')

local setup = require('scripts/belt-highlight/setup')
local highlight_queue = require('scripts/belt-highlight/highlight-queue')
local destroy_queue = require('scripts/belt-highlight/destroy-queue')
local show_underground_sprites = require('scripts/belt-highlight/undergrounds')

--[[
    global.destroy_queue -- array of indexes used to destroy
    global.highlight_queue -- array of information used to highlight
    pdata.markers -- array of rendering indexes
    pdata.belts -- dictionary unit -> belt connected belts
    pdata.belt_end_points -- end points left to walk
    pdata.undergrounds  -- used in underground marking
--]]
local function on_selected_entity_changed(event)
    local player, pdata = Player.get(event.player_index)
    if player.is_shortcut_toggled('picker-belt-highlighter') and player.game_view_settings.show_entity_info then
        local selected = player.selected
        if selected and setup.allowed_types[selected.type] then
            if not pdata.belts[selected.unit_number] then
                -- Start over
                destroy_queue(pdata)
                pdata.belts = {}
            end
            --walk_belts()
            highlight_queue(pdata, 'belts')
        else
            destroy_queue(pdata)
            pdata.belts = {}
        end
    end -- Toggled off, or alt-mode off
end
--Event.register(defines.events.on_selected_entity_changed, on_selected_entity_changed)

local function highlight_underground(event)
    local _, pdata = Player.get(event.player_index)
    if next(pdata.markers) then
        destroy_queue(pdata)
        pdata.undergrounds = {}
    else
        show_underground_sprites(event)
    end
end
Event.register('picker-show-underground-belt-paths', highlight_underground)

-- Toggle the shortcut
local function on_lua_shortcut(event)
    if event.prototype_name == 'picker-belt-highlighter' then
        local player = Player.get(event.player_index)
        if player.is_shortcut_available('picker-belt-highlighter') then
            player.set_shortcut_toggled('picker-belt-highlighter', not player.is_shortcut_toggled('picker-belt-highlighter'))
        end
    end
end
Event.register(defines.events.on_lua_shortcut, on_lua_shortcut)

-- Player toggle alt-mode, either highlight or remove if needed
local function on_player_toggled_alt_mode(event)
    local player, pdata = Player.get(event.player_index)
    if not player.game_view_settings.show_entity_info then
        if pdata.markers and next(pdata.markers) then
            destroy_queue(pdata)
            pdata.belts = {}
            pdata.undergrounds = {}
            pdata.belt_end_points = {}
        end
    else
        on_selected_entity_changed(event)
    end
end
Event.register(defines.events.on_player_toggled_alt_mode, on_player_toggled_alt_mode)

-- Toggle the shortcut on as soon as the player becomes available
--! API request to set default state on toggle creation
local function on_player_created(event)
    local player = Player.get(event.player_index)
    if player.is_shortcut_available('picker-belt-highlighter') then
        player.set_shortcut_toggled('picker-belt-highlighter', true)
    end
end
Event.register(defines.events.on_player_created, on_player_created)

Player.additional_data({belts = {}, undergrounds = {}, markers = {}})
