local Setup = require('setup')

local function read_forward_belt(entity_t, surface, forward_position)
    local find_belt = surface.find_entities_filtered
    return find_belt(
        {
            position = forward_position,
            type = {'transport-belt', 'underground-belt', 'splitter'},
            direction = Setup.find_direction_map[entity_t.direction]
        }
    )[1]
end

local function read_forward_splitter(entity_t, surface)
    local find_belt = surface.find_entities_filtered
    local shift_directions = Setup.splitter_check_table[entity_t.direction]
    local left_pos = entity_t.position + shift_directions.left
    local right_pos = entity_t.position + shift_directions.right
    return {
        left_entity = {
            entity = find_belt(
                {
                    position = left_pos,
                    type = {'transport-belt', 'underground-belt', 'splitter'},
                    direction = Setup.find_direction_map[entity_t.direction]
                }
            )[1],
            position = left_pos
        },
        right_entity = {
            entity = find_belt(
                {
                    position = right_pos,
                    type = {'transport-belt', 'underground-belt', 'splitter'},
                    direction = Setup.find_direction_map[entity_t.direction]
                }
            )[1],
            position = right_pos
        }
    }
end

local function read_forward_ug_belt(entity_t, surface, forward_position)
    local find_belt = surface.find_entities_filtered
    if entity_t.belt_to_ground_type == "input" then
        return entity_t.entity.neighbour
    else
        return find_belt(
            {
                position = forward_position,
                type = {'transport-belt', 'underground-belt', 'splitter'},
                direction = Setup.find_direction_map[entity_t.direction]
            }
        )[1]
    end
end

local function belt_walker(entity, pdata)
    local visited_belts = {}
    local counter = 1
    belts_forward[selected.unit_number] = {entity = selected}
    visited_belts[selected.unit_number] = true



end



return belt_walker
