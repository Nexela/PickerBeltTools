local Event = require('__stdlib__/stdlib/event/event')
local setup = require('scripts/belt-highlight/setup')

local function highlight_queue(queue_index, queue)
    local counter, MAX = 0, 100 -- Map setting of Max belts per tick.
    for index, orders in pairs(queue) do
        local pdata = global.players[orders.player_index]
        for _, draw_order in pairs(orders.draw) do
            pdata.markers[#pdata.markers + 1] = rendering[draw_order.type](draw_order)
        end
        queue[index] = nil
        counter = counter + 1
        if counter == MAX then
            break
        end
    end
    -- If this queue is fully empty then nil it.
    if not next(global.highlight_queue[queue_index]) then
        global.highlight_queue[queue_index] = nil
        return true
    end
end

local function highlight_handler()
    local index, queue = next(global.highlight_queue)
    if index then
        highlight_queue(index, queue)
    else
        remote.call("PickerAtheneum","queue_remove",{token = global.queue_token})
        Event.remove(global.queue_token,highlight_handler)
        global.queue_token = nil
    end
end

local function add_to_highlight_queue(pdata, table_name)
    if next(pdata[table_name]) then
        if global.highlight_queue and not next(global.highlight_queue) then
            local token = remote.call("PickerAtheneum","queue_add",{mod_name = "PickerBeltTools_highlight"})
            global.queue_token = token
            Event.register(token, highlight_handler, nil, nil, setup.tick_options)
            --Event.register(defines.events.on_tick, highlight_handler, nil, nil, setup.tick_options)
        end
        global.highlight_queue[#global.highlight_queue + 1] = pdata[table_name]
        pdata[table_name] = {}
        return true
    end
end

local function on_load()
    if global.highlight_queue and next(global.highlight_queue) then
        if global.queue_token then
            local token = remote.call("PickerAtheneum","queue_reestablish",{mod_name = "PickerBeltTools_highlight"})
            global.queue_token = token
            Event.register(token, highlight_handler)
        end
    end
end
Event.on_load(on_load)

local function on_init()
    global.highlight_queue = {}
end
Event.on_init(on_init)

local function on_configuration_changed()
    global.highlight_queue = global.destroy_queue or {}
end
Event.on_configuration_changed(on_configuration_changed)

return add_to_highlight_queue
