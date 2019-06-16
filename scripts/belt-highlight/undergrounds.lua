local Player = require('__stdlib__/stdlib/event/player')
local Position = require('__stdlib__/stdlib/area/position')

local setup = require('scripts/belt-highlight/setup')
local highlight_queue = require('scripts/belt-highlight/highlight-queue')

-- Store the belts in pdata.belts
local function show_underground_sprites(event)
    local player, pdata = Player.get(event.player_index)
    pdata.undergrounds = {}
    local surface = player.surface

    local radius = settings.global['picker-underground-search-radius'].value

    local filter = {
        area = Position(player.position):expand_to_area(radius),
        type = 'underground-belt',
        force = player.force
    }

    for _, underground in pairs(player.surface.find_entities_filtered(filter)) do
        local unit = underground.unit_number
        pdata.undergrounds[unit] = {
            entity = underground,
            player_index = player.index,
            marker_table = 'ug_markers'
        }
        local neighbour = underground.neighbours
        local offset = setup.ug_marker_table[underground.direction]
        pdata.undergrounds[unit].draw = {
            {
                type = 'draw_sprite',
                sprite = neighbour and 'picker-belt-marker-box-good' or 'picker-belt-marker-box-bad',
                target = underground,
                surface = surface,
                only_in_alt_mode = true,
                players = {event.player_index}
            }
        }
        if neighbour and not pdata.undergrounds[neighbour.unit_number] then
            local line1 = {
                type = 'draw_line',
                color = {r = 1, g = 1, b = 0, a = 1},
                width = 3,
                gap_length = 0.5,
                dash_length = 0.5,
                from = underground, --start_position + ug_marker.left,
                from_offset = offset.left,
                to = neighbour, --end_position + ug_marker.rev_left,
                to_offset = offset.rev_left,
                surface = surface,
                only_in_alt_mode = true,
                players = {event.player_index}
            }
            local line2 = {
                type = 'draw_line',
                color = {r = 1, g = 1, b = 0, a = 1},
                width = 3,
                gap_length = 0.5,
                dash_length = 0.5,
                from = underground, --start_position + ug_marker.left,
                from_offset = offset.right,
                to = neighbour, --end_position + ug_marker.rev_left,
                to_offset = offset.rev_right,
                surface = surface,
                only_in_alt_mode = true,
                players = {event.player_index}
            }
            table.insert(pdata.undergrounds[unit].draw, line1)
            table.insert(pdata.undergrounds[unit].draw, line2)
        end
    end

    highlight_queue(pdata, 'undergrounds')
end

return show_underground_sprites
