--[[
-- "name": "underground-pipe-pack",
-- "title": "Advanced Underground Piping",
-- "author": "TheStaplergun",
-- "contact": "TheStaplergun 2.0#6920 (DISCORD)",
-- "description": "Adds new functionality to underground piping.",
--]]
local Event = require('__stdlib__/event/event')
local Position = require('__stdlib__/area/position')

local function show_underground_sprites(event)
    local player = game.players[event.player_index]
    for _, entity in pairs(player.surface.find_entities_filtered {area = Position.expand_to_area(player.position, 64), type = 'pipe-to-ground'}) do
        player.surface.create_entity {
            name = 'pipe-marker-box',
            position = {entity.position.x, entity.position}
        }
        for _, entities in pairs(entity.neighbours) do
            for _, neighbour in pairs(entities) do
                if (entity.position.x - neighbour.position.x) < -1.5 then
                    local distancex = neighbour.position.x - entity.position.x
                    for i = 1, distancex - 1, 1 do
                        player.surface.create_entity {
                            name = 'underground-pipe-marker-horizontal',
                            position = {entity.position.x + i, entity.position.y}
                        }
                    end
                end
                if (entity.position.y - neighbour.position.y) < -1.5 then
                    local distancey = neighbour.position.y - entity.position.y
                    for i = 1, distancey - 1, 1 do
                        player.surface.create_entity {
                            name = 'underground-pipe-marker-vertical',
                            position = {entity.position.x, entity.position.y + i}
                        }
                    end
                end
            end
        end
    end
end

Event.register('show-underground-sprites', show_underground_sprites)
