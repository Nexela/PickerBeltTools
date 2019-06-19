-------------------------------------------------------------------------------
--[[Belt Highlighter]] --
-------------------------------------------------------------------------------
-- Concept designed and code written by TheStaplergun (staplergun on mod portal)
-- STDLib and code reviews provided by Nexela

local Event = require('__stdlib__/stdlib/event/event')
local Player = require('__stdlib__/stdlib/event/player')
local Position = require('__stdlib__/stdlib/area/position')
local Direction = require('__stdlib__/stdlib/area/direction')

local op_dir = Direction.opposite_direction
local max_belts = 2
local empty = {}
local create_sprite = rendering.draw_sprite
local create_line = rendering.draw_line




local bor = bit32.bor
local lshift = bit32.lshift
local function highlight_belts(selected_entity, player_index, forward, backward, stitch_data)
    local player, pdata = Player.get(player_index)
    --local belt_table = {}
    local read_entity_data = {}
    local all_entities_marked = pdata.current_beltnet_table and pdata.current_beltnet_table or {}
    local all_markers = pdata.current_marker_table and pdata.current_marker_table or {}

    local belts_read = 0
    --local belts_read = 0
    local markers_made = next(all_markers) and #all_markers or 0

    --? Assign working table references to global reference under player
    pdata.current_marker_table = all_markers
    pdata.current_beltnet_table = all_entities_marked

    pdata.scheduled_markers = pdata.scheduled_markers or {}

    local working_table = 1
    if pdata.scheduled_markers[1] and next(pdata.scheduled_markers[1]) then
        working_table = 2
    end
    pdata.scheduled_markers[working_table] = pdata.scheduled_markers[working_table] or {}

    --? Cache functions used more than once
    local find_belt = player.surface.find_entities_filtered
    local surface = player.surface

    local function read_forward_belt(forward_position)
        return find_belt(
            {
                position = forward_position,
                type = {'transport-belt', 'underground-belt', 'splitter'}
            }
        )[1]
    end

    -- TODO Make two individual point checks and return two entry table
    local function read_forward_splitter(entity_position, entity_direction)
        local shift_directions = splitter_check_table[entity_direction]
        local left_pos = entity_position + shift_directions.left
        local right_pos = entity_position + shift_directions.right
        return {
            left_entity = {
                entity = find_belt(
                    {
                        position = left_pos,
                        type = {'transport-belt', 'underground-belt', 'splitter'}
                    }
                )[1],
                position = left_pos
            },
            right_entity = {
                entity = find_belt(
                    {
                        position = right_pos,
                        type = {'transport-belt', 'underground-belt', 'splitter'}
                    }
                )[1],
                position = right_pos
            }
        }
    end

    local function get_splitter_input_side(entity_position, entity_direction, splitter_position)
        local delta_x = entity_position.x - splitter_position.x
        local delta_y = entity_position.y - splitter_position.y
        if entity_direction == defines.direction.north then
            return delta_x < 0 and 'left' or 'right'
        elseif entity_direction == defines.direction.east then
            return delta_y < 0 and 'left' or 'right'
        elseif entity_direction == defines.direction.south then
            return delta_x < 0 and 'right' or 'left'
        elseif entity_direction == defines.direction.west then
            return delta_y < 0 and 'right' or 'left'
        end
    end

    local function get_directions_ug_belt(current_entity)
        local table_entry = 0
        local entity_neighbours = current_entity[2]
        table_entry = current_entity[2].output_target and bor(table_entry, lshift(1, current_entity[4])) or table_entry
        if entity_neighbours.input then
            for _, direction_data in pairs(entity_neighbours.input) do
                table_entry = bor(table_entry, lshift(1, op_dir(direction_data[2])))
            end
        end
        return table_entry
    end

    local function mark_ug_belt(unit_number, current_entity)
        markers_made = markers_made + 1
        local map_dir = current_entity[4] / 2
        local graphics_change = (16 * map_dir) + marker_entry[get_directions_ug_belt(current_entity)]
        local new_marker =
            create_sprite {
            sprite = 'picker-ug-belt-marker-' .. graphics_change,
            target = current_entity[1],
            surface = surface,
            only_in_alt_mode = true,
            players = {player_index}
        }
        all_markers[markers_made] = new_marker
        all_entities_marked[unit_number] = true
    end

    local function mark_ug_segment(start_position, end_position, entity_direction)
        local ug_marker = ug_marker_table[entity_direction]
        markers_made = markers_made + 1
        all_markers[markers_made] =
            create_line {
            color = {r = 1, g = 1, b = 0, a = 1},
            width = 3,
            gap_length = 0.5,
            dash_length = 0.5,
            from = start_position + ug_marker.left,
            to = end_position + ug_marker.rev_left,
            surface = surface,
            only_in_alt_mode = true,
            players = {player_index}
        }
        markers_made = markers_made + 1
        all_markers[markers_made] =
            create_line {
            color = {r = 1, g = 1, b = 0, a = 1},
            width = 3,
            gap_length = 0.5,
            dash_length = 0.5,
            from = start_position + ug_marker.right,
            to = end_position + ug_marker.rev_right,
            surface = surface,
            only_in_alt_mode = true,
            players = {player_index}
        }
    end
    --))

    local function get_directions_belt(current_entity)
        local table_entry = 0
        local entity_neighbours = current_entity[2]
        if entity_neighbours.input then
            for _, direction_data in pairs(entity_neighbours.input) do
                table_entry = bor(table_entry, lshift(1, op_dir(direction_data[2])))
            end
        end
        table_entry = current_entity[2].output_target and bor(table_entry, lshift(1, current_entity[4])) or table_entry
        return table_entry
    end

    local function mark_belt(unit_number, current_entity)
        markers_made = markers_made + 1
        local map_dir = current_entity[4] / 2
        local graphics_change = (16 * map_dir) + bitwise_marker_entry[get_directions_belt(current_entity)]
        local new_marker =
            create_sprite {
            sprite = 'picker-belt-marker-' .. graphics_change,
            target = current_entity[1],
            surface = surface,
            only_in_alt_mode = true,
            players = {player_index}
        }
        all_markers[markers_made] = new_marker
        all_entities_marked[unit_number] = true
    end

    local function get_directions_splitter(current_entity)
        local neighbours = current_entity[2]
        local directions_map = 0
        directions_map = neighbours.left_output_target and bor(directions_map, lshift(1, 0)) or directions_map
        directions_map = neighbours.right_output_target and bor(directions_map, lshift(1, 2)) or directions_map
        directions_map = neighbours.right and bor(directions_map, lshift(1, 4)) or directions_map
        directions_map = neighbours.left and bor(directions_map, lshift(1, 6)) or directions_map
        return directions_map
    end

    local function mark_splitter(unit_number, current_entity)
        markers_made = markers_made + 1
        local graphics_change = bitwise_marker_entry[get_directions_splitter(current_entity)]
        local new_marker =
            create_sprite {
            sprite = map_direction[current_entity[4]] .. '-' .. graphics_change,
            target = current_entity[1],
            surface = surface,
            only_in_alt_mode = true,
            players = {player_index}
        }
        all_markers[markers_made] = new_marker
        all_entities_marked[unit_number] = true
    end

    local function cache_forward_ug_belt_connector(entity, entity_unit_number, entity_position, entity_type, entity_direction, belt_to_ground_direction, previous_entity_unit_number, previous_entity_direction, previous_entity_input_side)
        local entity_neighbours = {}
        if previous_entity_input_side then
            entity_neighbours[previous_entity_input_side] = previous_entity_unit_number
        else
            entity_neighbours.input = previous_entity_unit_number and {{previous_entity_unit_number, previous_entity_direction}} or {}
        end
        --? Cache current entity
        local current_entity
        if not read_entity_data[entity_unit_number] then
            current_entity =
            {
                entity_position,
                entity_neighbours,
                entity_type,
                entity_direction,
                entity,
                belt_to_ground_direction
            }
            read_entity_data[entity_unit_number] = current_entity
            --belts_read = belts_read + 1
        end
        --belts_read = belts_read + 1
        --rendering.draw_text{text = belts_read, surface = surface, color = {1,1,1,1}, target = entity_position}

    end

    local function read_belts(starter_entity)
        local starter_unit_number = starter_entity.unit_number
        local starter_entity_direction = starter_entity.direction
        local starter_entity_type = starter_entity.type
        local starter_entity_position = starter_entity.position

        local function step_forward(entity, entity_unit_number, entity_position, entity_type, entity_direction, belt_to_ground_direction, previous_entity_unit_number, previous_entity_direction, previous_entity_input_side)
            local entity_neighbours = {}
            if previous_entity_input_side then
                entity_neighbours[previous_entity_input_side] = previous_entity_unit_number
            elseif belt_to_ground_direction ~= 'output' then
                entity_neighbours.input = previous_entity_unit_number and {{previous_entity_unit_number, previous_entity_direction}} or {}
            else
                entity_neighbours.ug_input = previous_entity_unit_number and previous_entity_unit_number
            end
            --? Cache current entity
            local current_entity
            if not read_entity_data[entity_unit_number] then
                current_entity =
                {
                    entity_position,
                    entity_neighbours,
                    entity_type,
                    entity_direction,
                    entity,
                    belt_to_ground_direction
                }
                read_entity_data[entity_unit_number] = current_entity
                belts_read = belts_read + 1
            end
            --rendering.draw_text{text = belts_read, surface = surface, color = {1,1,1,1}, target = entity_position}
            --? Underground belt handling
            if entity_type == 'underground-belt' then
                --? Transport belt stepping
                local ug_neighbour = entity.neighbours
                local ug_belt_to_ground_type = entity.belt_to_ground_type
                --? UG Belts always return an entity reference as the neighbour
                if ug_belt_to_ground_type == 'input' then
                    read_entity_data[entity_unit_number][6] = ug_belt_to_ground_type
                    if ug_neighbour then
                        local ug_neighbour_type = 'underground-belt'
                        local ug_neighbour_direction = entity_direction
                        local ug_neighbour_position = ug_neighbour.position
                        local ug_neighbour_unit_number = ug_neighbour.unit_number
                        entity_neighbours.ug_output_target = ug_neighbour_unit_number
                        if not all_entities_marked[ug_neighbour_unit_number] then
                            if not read_entity_data[ug_neighbour_unit_number] then
                                if belts_read < max_belts then
                                    return step_forward(ug_neighbour, ug_neighbour_unit_number, ug_neighbour_position, ug_neighbour_type, ug_neighbour_direction, 'output', entity_unit_number, entity_direction, nil)
                                else
                                    global.marking = true
                                    global.marking_players[player_index] = true
                                    local wt = pdata.scheduled_markers[working_table]
                                    wt[#wt + 1] = {
                                        ug_neighbour,
                                        'forward',
                                        {
                                            'output',
                                            false,
                                            false
                                        }
                                    }
                                    return cache_forward_ug_belt_connector(ug_neighbour, ug_neighbour_unit_number, ug_neighbour_position, ug_neighbour_type, ug_neighbour_direction, 'output', entity_unit_number, entity_direction, nil)
                                end
                            else
                                local input = read_entity_data[ug_neighbour_unit_number][2].input
                                if input then
                                    input[#input + 1] = {entity_unit_number, entity_direction}
                                else
                                    read_entity_data[ug_neighbour_unit_number][2].input = {{entity_unit_number, entity_direction}}
                                end
                            end
                        end
                    end
                else
                    local forward_position = Position(entity_position):translate(entity_direction, 1)
                    local forward_entity = read_forward_belt(forward_position)
                    if forward_entity then
                        local forward_entity_direction = forward_entity.direction
                        local forward_entity_type = forward_entity.type
                        if not (forward_entity_direction == op_dir(entity_direction)) and not (forward_entity_type == 'underground-belt' and forward_entity_direction == entity_direction and forward_entity.belt_to_ground_type == 'output') and not (forward_entity_type == 'splitter' and forward_entity_direction ~= entity_direction) then
                            local forward_entity_unit_number = forward_entity.unit_number
                            entity_neighbours.output_target = forward_entity_unit_number
                            local splitter_input_side
                            if forward_entity_type == 'splitter' then
                                forward_position = forward_entity.position
                                splitter_input_side = get_splitter_input_side(entity_position, entity_direction, forward_position)
                            end
                            if not all_entities_marked[forward_entity_unit_number] then
                                if not read_entity_data[forward_entity_unit_number] then
                                    if belts_read < max_belts then
                                        return step_forward(forward_entity, forward_entity_unit_number, forward_position, forward_entity_type, forward_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                    else
                                        --cache_forward_ug_belt_connector(forward_entity, forward_entity_unit_number, forward_position, forward_entity_type, forward_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                        global.marking = true
                                        global.marking_players[player_index] = true
                                        local wt = pdata.scheduled_markers[working_table]
                                        wt[#wt + 1] = {
                                            forward_entity,
                                            'forward',
                                            {
                                                false,
                                                splitter_input_side,
                                                entity_direction,
                                                entity_unit_number
                                            }
                                        }
                                    end
                                else
                                    if forward_entity_type ~= 'splitter' then
                                        local input = read_entity_data[forward_entity_unit_number][2].input
                                        input[#input + 1] = {entity_unit_number, entity_direction}
                                    else
                                        local neighbours = read_entity_data[forward_entity_unit_number][2]
                                        neighbours[splitter_input_side] = entity_unit_number
                                    end
                                end
                            end
                        end
                    end
                end
            elseif entity_type == 'transport-belt' then
                --? Splitter handling
                local forward_position = Position(entity_position):translate(entity_direction, 1)
                local forward_entity = read_forward_belt(forward_position)
                if forward_entity then
                    local forward_entity_direction = forward_entity.direction
                    local forward_entity_type = forward_entity.type
                    if not (forward_entity_direction == op_dir(entity_direction)) and not (forward_entity_type == 'underground-belt' and forward_entity_direction == entity_direction and forward_entity.belt_to_ground_type == 'output') and not (forward_entity_type == 'splitter' and forward_entity_direction ~= entity_direction) then
                        local forward_entity_unit_number = forward_entity.unit_number
                        entity_neighbours.output_target = forward_entity_unit_number
                        local splitter_input_side
                        if forward_entity_type == 'splitter' then
                            forward_position = forward_entity.position
                            splitter_input_side = get_splitter_input_side(entity_position, entity_direction, forward_position)
                        end
                        if not all_entities_marked[forward_entity_unit_number] then
                            if not read_entity_data[forward_entity_unit_number] then
                                if belts_read < max_belts then
                                    return step_forward(forward_entity, forward_entity_unit_number, forward_position, forward_entity_type, forward_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                else
                                    --cache_forward_ug_belt_connector(forward_entity, forward_entity_unit_number, forward_position, forward_entity_type, forward_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                    global.marking = true
                                    global.marking_players[player_index] = true
                                    local wt = pdata.scheduled_markers[working_table]
                                    wt[#wt + 1] = {
                                        forward_entity,
                                        'forward',
                                        {
                                            false,
                                            splitter_input_side,
                                            entity_direction,
                                            entity_unit_number
                                        }
                                    }
                                end
                            else
                                if forward_entity_type ~= 'splitter' then
                                    local input = read_entity_data[forward_entity_unit_number][2].input
                                    input[#input + 1] = {entity_unit_number, entity_direction}
                                else
                                    local neighbours = read_entity_data[forward_entity_unit_number][2]
                                    neighbours[splitter_input_side] = entity_unit_number
                                end
                            end
                        end
                    end
                end
            elseif entity_type == 'splitter' then
                local forward_entities = read_forward_splitter(entity_position, entity_direction)
                if forward_entities.left_entity.entity then
                    local left_entity_direction = forward_entities.left_entity.entity.direction
                    local left_entity_type = forward_entities.left_entity.entity.type
                    local left_entity_position = forward_entities.left_entity.position
                    if not (left_entity_direction == op_dir(entity_direction)) and not (left_entity_type == 'underground-belt' and left_entity_direction == entity_direction and forward_entities.left_entity.entity.belt_to_ground_type == 'output') and not (left_entity_type == 'splitter' and left_entity_direction ~= entity_direction) then
                        local left_entity_unit_number = forward_entities.left_entity.entity.unit_number
                        entity_neighbours.left_output_target = left_entity_unit_number
                        local splitter_input_side
                        if left_entity_type == 'splitter' then
                            left_entity_position = forward_entities.left_entity.entity.position
                            splitter_input_side = get_splitter_input_side(entity_position, entity_direction, left_entity_position)
                        end
                        if not all_entities_marked[left_entity_unit_number] then
                            if not read_entity_data[left_entity_unit_number] then
                                if belts_read < max_belts then
                                    if forward_entities.right_entity.entity then
                                        step_forward(forward_entities.left_entity.entity, left_entity_unit_number, left_entity_position, left_entity_type, left_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                    else
                                        return step_forward(forward_entities.left_entity.entity, left_entity_unit_number, left_entity_position, left_entity_type, left_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                    end
                                else
                                    --cache_forward_ug_belt_connector(forward_entities.left_entity.entity, left_entity_unit_number, left_entity_position, left_entity_type, left_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                    global.marking = true
                                    global.marking_players[player_index] = true
                                    local wt = pdata.scheduled_markers[working_table]
                                    wt[#wt + 1] = {
                                        forward_entities.left_entity.entity,
                                        'forward',
                                        {
                                            false,
                                            splitter_input_side,
                                            entity_direction,
                                            entity_unit_number
                                        }
                                    }
                                end
                            else
                                if left_entity_type ~= 'splitter' then
                                    local input = read_entity_data[left_entity_unit_number][2].input
                                    input[#input + 1] = {entity_unit_number, entity_direction}
                                else
                                    local neighbours = read_entity_data[left_entity_unit_number][2]
                                    neighbours[splitter_input_side] = entity_unit_number
                                end
                            end
                        end
                    end
                end
                if forward_entities.right_entity.entity then
                    local right_entity_direction = forward_entities.right_entity.entity.direction
                    local right_entity_type = forward_entities.right_entity.entity.type
                    local right_entity_position = forward_entities.right_entity.position
                    if not (right_entity_direction == op_dir(entity_direction)) and not (right_entity_type == 'underground-belt' and right_entity_direction == entity_direction and forward_entities.right_entity.entity.belt_to_ground_type == 'output') and not (right_entity_type == 'splitter' and right_entity_direction ~= entity_direction) then
                        local right_entity_unit_number = forward_entities.right_entity.entity.unit_number
                        entity_neighbours.right_output_target = right_entity_unit_number
                        local splitter_input_side
                        if right_entity_type == 'splitter' then
                            right_entity_position = forward_entities.right_entity.entity.position
                            splitter_input_side = get_splitter_input_side(entity_position, entity_direction, right_entity_position)
                        end
                        if not all_entities_marked[right_entity_unit_number] then
                            if not read_entity_data[right_entity_unit_number] then
                                if belts_read < max_belts then
                                    return step_forward(forward_entities.right_entity.entity, right_entity_unit_number, right_entity_position, right_entity_type, right_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                else
                                    --cache_forward_ug_belt_connector(forward_entities.right_entity.entity, right_entity_unit_number, right_entity_position, right_entity_type, right_entity_direction, nil, entity_unit_number, entity_direction, splitter_input_side)
                                    global.marking = true
                                    global.marking_players[player_index] = true
                                    local wt = pdata.scheduled_markers[working_table]
                                    wt[#wt + 1] = {
                                        forward_entities.right_entity.entity,
                                        'forward',
                                        {
                                            false,
                                            splitter_input_side,
                                            entity_direction,
                                            entity_unit_number
                                        }
                                    }
                                end
                            else
                                if right_entity_type ~= 'splitter' then
                                    local input = read_entity_data[right_entity_unit_number][2].input
                                    input[#input + 1] = {entity_unit_number, entity_direction}
                                else
                                    local neighbours = read_entity_data[right_entity_unit_number][2]
                                    neighbours[splitter_input_side] = entity_unit_number
                                end
                            end
                        end
                    end
                end
            end
        end
        if forward then
            local belt_to_ground_direction = stitch_data and stitch_data[1] or starter_entity_type == 'underground-belt' and starter_entity.belt_to_ground_type
            step_forward(starter_entity, starter_unit_number, starter_entity_position, starter_entity_type, starter_entity_direction, belt_to_ground_direction, stitch_data and stitch_data[4], stitch_data and stitch_data[3], stitch_data and stitch_data[2])
        end

        local function read_backward_belt(current_entity)
            local left_feed_direction_check = (current_entity[4] + 6) % 8
            local rear_feed_direction_check = op_dir(current_entity[4])
            local right_feed_direction_check = (current_entity[4] + 2) % 8
            local left_feed_position = Position(current_entity[1]):translate(left_feed_direction_check, 1)
            local rear_feed_position = Position(current_entity[1]):translate(rear_feed_direction_check, 1)
            local right_feed_position = Position(current_entity[1]):translate(right_feed_direction_check, 1)
            local left_feed_entity =
                find_belt(
                {
                    position = left_feed_position,
                    type = {'transport-belt', 'underground-belt', 'splitter'}
                }
            )[1]
            local rear_feed_entity =
                find_belt(
                {
                    position = rear_feed_position,
                    type = {'transport-belt', 'underground-belt', 'splitter'}
                }
            )[1]
            local right_feed_entity =
                find_belt(
                {
                    position = right_feed_position,
                    type = {'transport-belt', 'underground-belt', 'splitter'}
                }
            )[1]
            local backstep_data = {}
            local left_feed_direction = left_feed_entity and left_feed_entity.direction or nil
            local rear_feed_direction = rear_feed_entity and rear_feed_entity.direction or nil
            local right_feed_direction = right_feed_entity and right_feed_entity.direction or nil
            if left_feed_direction and left_feed_direction == op_dir(left_feed_direction_check) then
                local left_feed_type = left_feed_entity.type
                local belt_to_ground_direction = left_feed_type == 'underground-belt' and left_feed_entity.belt_to_ground_type
                if belt_to_ground_direction ~= 'input' then
                    backstep_data.left_feed_entity_data = {
                        left_feed_position,
                        {},
                        left_feed_type,
                        left_feed_direction,
                        left_feed_entity,
                        belt_to_ground_direction
                    }
                end
            end
            if rear_feed_direction and rear_feed_direction == op_dir(rear_feed_direction_check) then
                local rear_feed_type = rear_feed_entity.type
                local belt_to_ground_direction = rear_feed_type == 'underground-belt' and rear_feed_entity.belt_to_ground_type
                if belt_to_ground_direction ~= 'input' then
                    backstep_data.rear_feed_entity_data = {
                        rear_feed_position,
                        {},
                        rear_feed_type,
                        rear_feed_direction,
                        rear_feed_entity,
                        belt_to_ground_direction
                    }
                end
            end
            if right_feed_direction and right_feed_direction == op_dir(right_feed_direction_check) then
                local right_feed_type = right_feed_entity.type
                local belt_to_ground_direction = right_feed_type == 'underground-belt' and right_feed_entity.belt_to_ground_type
                if belt_to_ground_direction ~= 'input' then
                    backstep_data.right_feed_entity_data = {
                        right_feed_position,
                        {},
                        right_feed_type,
                        right_feed_direction,
                        right_feed_entity,
                        belt_to_ground_direction
                    }
                end
            end
            return backstep_data
        end

        local function read_sideload_ug_belt(current_entity)
            local left_feed_direction_check = (current_entity[4] + 6) % 8
            local right_feed_direction_check = (current_entity[4] + 2) % 8
            local left_feed_position = Position(current_entity[1]):translate(left_feed_direction_check, 1)
            local right_feed_position = Position(current_entity[1]):translate(right_feed_direction_check, 1)
            local left_feed_entity =
                find_belt(
                {
                    position = left_feed_position,
                    type = {'transport-belt', 'underground-belt', 'splitter'}
                }
            )[1]
            local right_feed_entity =
                find_belt(
                {
                    position = right_feed_position,
                    type = {'transport-belt', 'underground-belt', 'splitter'}
                }
            )[1]
            local backstep_data = {}
            local left_feed_direction = left_feed_entity and left_feed_entity.direction or nil
            local right_feed_direction = right_feed_entity and right_feed_entity.direction or nil
            if left_feed_direction and left_feed_direction == op_dir(left_feed_direction_check) then
                local left_feed_type = left_feed_entity.type
                local belt_to_ground_direction = left_feed_type == 'underground-belt' and left_feed_entity.belt_to_ground_type
                if belt_to_ground_direction ~= 'input' then
                    backstep_data.left_feed_entity_data = {
                        left_feed_position,
                        {},
                        left_feed_type,
                        left_feed_direction,
                        left_feed_entity,
                        belt_to_ground_direction
                    }
                end
            end
            if right_feed_direction and right_feed_direction == op_dir(right_feed_direction_check) then
                local right_feed_type = right_feed_entity.type
                local belt_to_ground_direction = right_feed_type == 'underground-belt' and right_feed_entity.belt_to_ground_type
                if belt_to_ground_direction ~= 'input' then
                    backstep_data.right_feed_entity_data = {
                        right_feed_position,
                        {},
                        right_feed_type,
                        right_feed_direction,
                        right_feed_entity,
                        belt_to_ground_direction
                    }
                end
            end
            return backstep_data
        end

        local function read_backward_splitter(current_entity)
            local shift_directions = splitter_check_table[op_dir(current_entity[4])]
            local left_feed_position = current_entity[1] + shift_directions.right
            local right_feed_position = current_entity[1] + shift_directions.left
            local left_feed_entity =
                find_belt(
                {
                    position = left_feed_position,
                    type = {'transport-belt', 'underground-belt', 'splitter'}
                }
            )[1]
            local right_feed_entity =
                find_belt(
                {
                    position = right_feed_position,
                    type = {'transport-belt', 'underground-belt', 'splitter'}
                }
            )[1]
            local backstep_data = {}
            local left_feed_direction = left_feed_entity and left_feed_entity.direction or nil
            local right_feed_direction = right_feed_entity and right_feed_entity.direction or nil
            if left_feed_direction and left_feed_direction == current_entity[4] then
                local left_feed_type = left_feed_entity.type
                local belt_to_ground_direction = left_feed_type == 'underground-belt' and left_feed_entity.belt_to_ground_type
                if belt_to_ground_direction ~= 'input' then
                    backstep_data.left_feed_entity_data = {
                        left_feed_position,
                        {},
                        left_feed_type,
                        left_feed_direction,
                        left_feed_entity,
                        belt_to_ground_direction
                    }
                end
            end
            if right_feed_direction and right_feed_direction == current_entity[4] then
                local right_feed_type = right_feed_entity.type
                local belt_to_ground_direction = right_feed_type == 'underground-belt' and right_feed_entity.belt_to_ground_type
                if belt_to_ground_direction ~= 'input' then
                    backstep_data.right_feed_entity_data = {
                        right_feed_position,
                        {},
                        right_feed_type,
                        right_feed_direction,
                        right_feed_entity,
                        belt_to_ground_direction
                    }
                end
            end
            return backstep_data
        end

        local function cache_backward_ug_belt_connector(entity, entity_unit_number, entity_position, entity_type, entity_direction, belt_to_ground_direction, previous_entity_unit_number, previous_entity_output_side)
            local entity_neighbours = read_entity_data[entity_unit_number] and read_entity_data[entity_unit_number][2] or {}
            if previous_entity_output_side then
                entity_neighbours[previous_entity_output_side] = previous_entity_unit_number
            else
                if previous_entity_unit_number then
                    if belt_to_ground_direction ~= 'input' and not entity_neighbours.output_target then
                        entity_neighbours.output_target = previous_entity_unit_number
                    elseif belt_to_ground_direction == 'input' and not entity_neighbours.ug_output_target then
                        entity_neighbours.ug_output_target = previous_entity_unit_number
                    end
                end
            end
            --? Cache current entity
            local current_entity
            if not read_entity_data[entity_unit_number] then
                current_entity =
                {
                    entity_position,
                    entity_neighbours,
                    entity_type,
                    entity_direction,
                    entity,
                    belt_to_ground_direction
                }
                read_entity_data[entity_unit_number] = current_entity
                --belts_read = belts_read + 1
            end
            --belts_read = belts_read + 1
            --rendering.draw_text{text = belts_read, surface = surface, color = {1,1,1,1}, target = entity_position}
        end

        local function step_backward(entity, entity_unit_number, entity_position, entity_type, entity_direction, belt_to_ground_direction, previous_entity_unit_number, previous_entity_output_side)
            local function check_backward(current_entity, neighbour)
                local entity_neighbours = current_entity[2]
                local neighbour_type = neighbour[3]
                local neighbour_position = neighbour_type == 'splitter' and neighbour[5].position or neighbour[1]
                local neighbour_direction = neighbour[4]
                local neighbour_unit_number = neighbour[5].unit_number
                entity_neighbours.input = entity_neighbours.input and entity_neighbours.input or {}
                entity_neighbours.input[#entity_neighbours.input + 1] = {neighbour_unit_number, neighbour_direction}
                local splitter_output_side
                if neighbour_type == 'splitter' then
                    splitter_output_side = get_splitter_input_side(neighbour_position, neighbour_direction, current_entity[1]) == 'right' and 'left_output_target' or 'right_output_target'
                end
                if not all_entities_marked[neighbour_unit_number] then
                    if not read_entity_data[neighbour_unit_number] then
                        if belts_read < max_belts then
                            return step_backward(neighbour[5], neighbour_unit_number, neighbour_position, neighbour_type, neighbour_direction, neighbour.belt_to_ground_direction, entity_unit_number, splitter_output_side)
                        else
                            --mark_scheduled_point(entity_unit_number, current_entity)
                            --return cache_backward_ug_belt_connector(neighbour[5], neighbour_unit_number, neighbour_position, neighbour_type, neighbour_direction, neighbour.belt_to_ground_direction, entity_unit_number, splitter_output_side)
                            global.marking = true
                            global.marking_players[player_index] = true
                            local wt = pdata.scheduled_markers[working_table]
                            wt[#wt + 1] = {
                                neighbour[5],
                                'backward',
                                {
                                    false,
                                    splitter_output_side,
                                    entity_unit_number
                                }
                            }
                        end
                    else
                        if neighbour_type ~= 'splitter' then
                            read_entity_data[neighbour_unit_number][2].output_target = entity_unit_number
                        else
                            read_entity_data[neighbour_unit_number][2][splitter_output_side] = entity_unit_number
                        end
                    end
                end
            end

            local entity_neighbours = read_entity_data[entity_unit_number] and read_entity_data[entity_unit_number][2] or {}
            if previous_entity_output_side then
                entity_neighbours[previous_entity_output_side] = previous_entity_unit_number
            else
                if previous_entity_unit_number then
                    if belt_to_ground_direction ~= 'input' and not entity_neighbours.output_target then
                        entity_neighbours.output_target = previous_entity_unit_number
                    elseif belt_to_ground_direction == 'input' and not entity_neighbours.ug_output_target then
                        entity_neighbours.ug_output_target = previous_entity_unit_number
                    end
                end
            end
            --? Cache current entity
            local current_entity
            if read_entity_data[entity_unit_number] then
                current_entity = read_entity_data[entity_unit_number]
            else
                current_entity =
                {
                    entity_position,
                    entity_neighbours,
                    entity_type,
                    entity_direction,
                    entity,
                    belt_to_ground_direction
                }
                belts_read = belts_read + 1.5
            end
            read_entity_data[entity_unit_number] = current_entity
            --rendering.draw_text{text = belts_read, surface = surface, color = {1,0,1,1}, target = entity_position}
            if entity_type == 'underground-belt' then
                local ug_neighbour = entity.neighbours
                local ug_belt_to_ground_type = entity.belt_to_ground_type
                if ug_belt_to_ground_type == 'output' then
                    read_entity_data[entity_unit_number][6] = ug_belt_to_ground_type
                    if ug_neighbour then
                        local ug_neighbour_type = 'underground-belt'
                        local ug_neighbour_direction = entity_direction
                        local ug_neighbour_position = ug_neighbour.position
                        local ug_neighbour_unit_number = ug_neighbour.unit_number
                        entity_neighbours.ug_input = ug_neighbour_unit_number
                        if not all_entities_marked[ug_neighbour_unit_number] then
                            if not read_entity_data[ug_neighbour_unit_number] then
                                if belts_read < max_belts then
                                    step_backward(ug_neighbour, ug_neighbour_unit_number, ug_neighbour_position, ug_neighbour_type, ug_neighbour_direction, 'input', entity_unit_number)
                                else
                                    global.marking = true
                                    global.marking_players[player_index] = true
                                    local wt = pdata.scheduled_markers[working_table]
                                    wt[#wt + 1] = {
                                        ug_neighbour,
                                        'backward',
                                        {
                                            'input',
                                            false,
                                            entity_unit_number
                                        }
                                    }
                                    cache_backward_ug_belt_connector(ug_neighbour, ug_neighbour_unit_number, ug_neighbour_position, ug_neighbour_type, ug_neighbour_direction, 'input', entity_unit_number)
                                end
                            else
                                read_entity_data[ug_neighbour_unit_number][2].output_target = {entity_unit_number, entity_direction}
                            end
                        end
                    end
                    local neighbours = read_sideload_ug_belt(current_entity)
                    if neighbours.left_feed_entity_data then
                        local neighbour = neighbours.left_feed_entity_data
                        check_backward(current_entity, neighbour)
                    end
                    if neighbours.right_feed_entity_data then
                        local neighbour = neighbours.right_feed_entity_data
                        check_backward(current_entity, neighbour)
                    end
                else
                    local neighbours = read_backward_belt(current_entity)
                    if neighbours.left_feed_entity_data then
                        local neighbour = neighbours.left_feed_entity_data
                        check_backward(current_entity, neighbour)
                    end
                    if neighbours.rear_feed_entity_data then
                        local neighbour = neighbours.rear_feed_entity_data
                        check_backward(current_entity, neighbour)
                    end
                    if neighbours.right_feed_entity_data then
                        local neighbour = neighbours.right_feed_entity_data
                        check_backward(current_entity, neighbour)
                    end
                end
            elseif entity_type == 'transport-belt' then
                local neighbours = read_backward_belt(current_entity)
                if neighbours.left_feed_entity_data then
                    local neighbour = neighbours.left_feed_entity_data
                    check_backward(current_entity, neighbour)
                end
                if neighbours.rear_feed_entity_data then
                    local neighbour = neighbours.rear_feed_entity_data
                    check_backward(current_entity, neighbour)
                end
                if neighbours.right_feed_entity_data then
                    local neighbour = neighbours.right_feed_entity_data
                    check_backward(current_entity, neighbour)
                end
            elseif entity_type == 'splitter' then
                local neighbours = read_backward_splitter(current_entity)
                if neighbours.left_feed_entity_data then
                    local neighbour = neighbours.left_feed_entity_data
                    local neighbour_type = neighbour[3]
                    local neighbour_position = neighbour_type == 'splitter' and neighbour[5].position or neighbour[1]
                    local neighbour_direction = neighbour[4]
                    local neighbour_unit_number = neighbour[5].unit_number
                    entity_neighbours.left = neighbour_unit_number
                    local splitter_output_side
                    if neighbour_type == 'splitter' then
                        splitter_output_side = get_splitter_input_side(neighbour_position, neighbour_direction, entity_position) == 'right' and 'left_output_target' or 'right_output_target'
                    end
                    if not all_entities_marked[neighbour_unit_number] then
                        if not read_entity_data[neighbour_unit_number] then
                            if belts_read < max_belts then
                                if neighbours.right_feed_entity_data then
                                    step_backward(neighbour[5], neighbour_unit_number, neighbour_position, neighbour_type, neighbour_direction, neighbour.belt_to_ground_direction, entity_unit_number, splitter_output_side)
                                else
                                    return step_backward(neighbour[5], neighbour_unit_number, neighbour_position, neighbour_type, neighbour_direction, neighbour.belt_to_ground_direction, entity_unit_number, splitter_output_side)
                                end
                            else
                                --mark_scheduled_point(entity_unit_number, current_entity)
                                --cache_backward_ug_belt_connector(neighbour[5], neighbour_unit_number, neighbour_position, neighbour_type, neighbour_direction, neighbour.belt_to_ground_direction, entity_unit_number, splitter_output_side)
                                global.marking = true
                                global.marking_players[player_index] = true
                                local wt = pdata.scheduled_markers[working_table]
                                wt[#wt + 1] = {
                                    neighbour[5],
                                    'backward',
                                    {
                                        false,
                                        splitter_output_side,
                                        entity_unit_number
                                    }
                                }
                            end
                        else
                            if neighbour_type ~= 'splitter' then
                                read_entity_data[neighbour_unit_number][2].output_target = entity_unit_number
                            else
                                read_entity_data[neighbour_unit_number][2][splitter_output_side] = entity_unit_number
                            end
                        end
                    end
                end
                if neighbours.right_feed_entity_data then
                    local neighbour = neighbours.right_feed_entity_data
                    local neighbour_type = neighbour[3]
                    local neighbour_position = neighbour_type == 'splitter' and neighbour[5].position or neighbour[1]
                    local neighbour_direction = neighbour[4]
                    local neighbour_unit_number = neighbour[5].unit_number
                    entity_neighbours.right = neighbour_unit_number
                    local splitter_output_side
                    if neighbour_type == 'splitter' then
                        splitter_output_side = get_splitter_input_side(neighbour_position, neighbour_direction, entity_position) == 'right' and 'left_output_target' or 'right_output_target'
                    end
                    if not all_entities_marked[neighbour_unit_number] then
                        if not read_entity_data[neighbour_unit_number] then
                            if belts_read < max_belts then
                                return step_backward(neighbour[5], neighbour_unit_number, neighbour_position, neighbour_type, neighbour_direction, neighbour.belt_to_ground_direction, entity_unit_number, splitter_output_side)
                            else
                                --mark_scheduled_point(entity_unit_number, current_entity)
                                --cache_backward_ug_belt_connector(neighbour[5], neighbour_unit_number, neighbour_position, neighbour_type, neighbour_direction, neighbour.belt_to_ground_direction, entity_unit_number, splitter_output_side)
                                global.marking = true
                                global.marking_players[player_index] = true
                                local wt = pdata.scheduled_markers[working_table]
                                wt[#wt + 1] = {
                                    neighbour[5],
                                    'backward',
                                    {
                                        false,
                                        splitter_output_side,
                                        entity_unit_number
                                    }
                                }
                            end
                        else
                            if neighbour_type ~= 'splitter' then
                                read_entity_data[neighbour_unit_number][2].output_target = entity_unit_number
                            else
                                read_entity_data[neighbour_unit_number][2][splitter_output_side] = entity_unit_number
                            end
                        end
                    end
                end
            end
        end
        if backward then
            local belt_to_ground_direction = stitch_data and stitch_data[1] and stitch_data[1] or starter_entity_type == 'underground-belt' and starter_entity.belt_to_ground_type
            step_backward(starter_entity, starter_unit_number, starter_entity_position, starter_entity_type, starter_entity_direction, belt_to_ground_direction, stitch_data and stitch_data[3], stitch_data and stitch_data[2])
        end
    end
    read_belts(selected_entity)

    for unit_number, current_entity in pairs(read_entity_data) do
        if not all_entities_marked[unit_number] then
            if current_entity[3] == 'underground-belt' and current_entity[6] == 'input' and current_entity[2].ug_output_target then
                local start_position = current_entity[1]
                local neighbour_entity_data = read_entity_data[current_entity[2].ug_output_target]
                local end_position = neighbour_entity_data[1]
                mark_ug_belt(unit_number, current_entity)
                mark_ug_segment(start_position, end_position, current_entity[4])
                all_entities_marked[unit_number] = true
            elseif current_entity[3] == 'transport-belt' then
                mark_belt(unit_number, current_entity)
            elseif current_entity[3] == 'splitter' then
                mark_splitter(unit_number, current_entity)
            else
                mark_ug_belt(unit_number, current_entity)
            end
        end
    end
    global.belts_marked_this_tick = global.belts_marked_this_tick + belts_read
    global.total_belts_marked = global.total_belts_marked + belts_read
end

local function highlight_scheduler()
    for player_index, _ in pairs(global.marking_players) do
        local _, pdata = Player.get(player_index)
        local wt = pdata.scheduled_markers and pdata.scheduled_markers[1]
        if wt and next(wt) then
            --break
            local next_belt = table.remove(wt, 1)
            if next_belt[1].valid then
                highlight_belts(next_belt[1], player_index, next_belt[2] == 'forward' and true or false, next_belt[2] == 'backward' and true or false, next_belt[3])
            end
        elseif pdata.scheduled_markers and not next(pdata.scheduled_markers[1]) and pdata.scheduled_markers[2] and next(pdata.scheduled_markers[2]) then
            table.remove(pdata.scheduled_markers, 1)
        else
            pdata.scheduled_markers = nil
            global.marking_players[player_index] = nil
        end
    end
    if not next(global.marking_players) then
        global.marking = false
        game.print(global.total_belts_marked)
    end
    if global.marking and global.belts_marked_this_tick < max_belts then
        return highlight_scheduler()
    end
end
local function tablelength(T)
    local count = 0
    if T then
        for _ in pairs(T) do count = count + 1 end
        return count
    end
  end

local function max_belts_handler()
    if global.marking then
        global.belts_marked_this_tick = 0
        highlight_scheduler()
    else
        global.belts_marked_this_tick = 0
        Event.remove(defines.events.on_tick, max_belts_handler)
        local _,pdata = Player.get(1)
        if pdata.current_beltnet_table and next(pdata.current_beltnet_table) then
            -- local p = game.create_profiler()
            -- game.print(tablelength(pdata.current_beltnet_table))
            -- game.print(p)
            -- p = nil
        end
    end
end