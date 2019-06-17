local function belt_walker(pdata, selected)
    local belts_forward = {}
    local belts_backwards = {}
    local visited_belts = {}
    local counter = 1
    belts_forward[selected.unit_number] = {entity = selected}
    visited_belts[selected.unit_number] = true
    game.print(selected.name)
    local player = game.get_player(pdata.index)
    player.create_local_flying_text{text = counter, position = selected.position, time_to_live = 600}

    local lines = selected.neighbours
    game.print(inspect(lines))
    -- while next(lines) do
    --     counter = counter + 1
    --     local belt = line[1].owner
    --     belts_forward[belt.unit_number] = {entity = belt}
    --     visited_belts[belt.unit_number] = true
    --     lines = lines[1].output_lines
    --     player.create_local_flying_text{text = counter, position = belt.position, time_to_live = 600}
    -- end

end



return belt_walker
