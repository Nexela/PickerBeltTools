local Event = require('__stdlib__/stdlib/event/event')
local setup = require('scripts/belt-highlight/setup')

-- Iterate the internal queue and destroy up to MAX marks per tick.
local function destroy_queue(queue_index, queue)
    local counter, MAX = 0, 100 -- Map setting of Max belts per tick.
    for index, mark in pairs(queue) do
        rendering.destroy(mark)
        queue[index] = nil
        counter = counter + 1
        if counter == MAX then
            break
        end
    end
    -- If this queue is fully empty then nil it.
    if not next(global.destroy_queue[queue_index]) then
        global.destroy_queue[queue_index] = nil
        return true
    end
end

-- The Tick Handler (registered selectivly), Handles x amount of one players queue per tick
-- until that players queue is empty, then moves on to another player next tick.
local function destroy_handler()
    local index, queue = next(global.destroy_queue)
    if index then
        destroy_queue(index, queue)
    else
        remote.call("PickerAtheneum","queue_remove",{token = global.queue_token})
        Event.remove(global.queue_token,destroy_handler())
        global.queue_token = nil
    end
end

-- The function used to swap markers to the destroy Queue
local function add_to_destroy_queue(pdata)
    if next(pdata.markers) then
        -- Start the ticker if it is not already running, destruction starts on the next tick
        if global.destroy_queue and not next(global.destroy_queue) then
            local token = remote.call("PickerAtheneum","queue_add",{mod_name = "PickerBeltTools_destroy"})
            global.queue_token = token
            Event.register(token, destroy_handler, nil, nil, setup.tick_options)
        end
        -- Swap the markers table to destroy queue, and create a new empty markers table
        global.destroy_queue[#global.destroy_queue + 1] = pdata.markers
        pdata.markers = {}
        -- stop the queue of anything else for this player?
        for queue_index, queue in pairs(global.highlight_queue) do
            local _, queue_data = next(queue)
            if queue_data and pdata.index == queue_data.player_index then
                global.highlight_queue[queue_index] = nil
            end
        end
        return true
    end
end

local function on_load()
    if global.destroy_queue and next(global.destroy_queue) then
        local token = remote.call("PickerAtheneum","queue_reestablish",{mod_name = "PickerBeltTools_destroy"})
        global.queue_token = token
        Event.register(token, destroy_handler)
    end
end
Event.on_load(on_load)

local function on_init()
    global.destroy_queue = {}
end
Event.on_init(on_init)

local function on_configuration_changed()
    global.destroy_queue = global.destroy_queue or {}
end
Event.on_configuration_changed(on_configuration_changed)

return add_to_destroy_queue
