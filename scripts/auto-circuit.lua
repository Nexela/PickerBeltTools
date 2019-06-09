local Event = require('__stdlib__/stdlib/event/event')

local function shortcut(event)
    if event.prototype_name == 'picker-auto-circuit' then
        local player = game.get_player(event.player_index)
        if player.is_shortcut_available('picker-auto-circuit') then
            player.set_shortcut_toggled('picker-auto-circuit', not player.is_shortcut_toggled('picker-auto-circuit'))
        end
    end
end
Event.register(defines.events.on_lua_shortcut, shortcut)

local function pole_check(entity)
    return entity.type == 'electric-pole' and entity.prototype.max_wire_distance >= 15
end

local function connect_wires(entity)
    local copper = entity.neighbours['copper']
    for _, pole in pairs(copper) do
        if pole_check(pole) then
            local red, green = pole.neighbours['green'], pole.neighbours['red']
            if #green > 0 then
                entity.connect_neighbour {
                    wire = defines.wire_type.green,
                    target_entity = pole
                }
            end
            if #red > 0 then
                entity.connect_neighbour {
                    wire = defines.wire_type.red,
                    target_entity = pole
                }
            end
        end
    end
end

local function on_built_entity(event)
    if pole_check(event.created_entity) then
        if event.name == defines.events.on_built_entity then
            local player = game.get_player(event.player_index)
            return player.is_shortcut_toggled('picker-auto-circuit') and connect_wires(event.created_entity)
        else
            return connect_wires(event.created_entity)
        end
    end
end
local events = {defines.events.on_robot_built_entity, defines.events.on_built_entity}
Event.register(events, on_built_entity)
