local Event = require('__stdlib__/stdlib/event/event')
local setup = require('scripts/belt-highlight/setup')

local function highlight_queue(queue_index, queue)
    local counter, MAX = 0, settings.global['picker-max-renders-tick'].value -- Map setting of Max belts per tick.
    for index, orders in pairs(queue) do
        local pdata = global.players[orders.player_index]
        pdata[orders.marker_table] = pdata[orders.marker_table] or {}
        local marker_table = pdata[orders.marker_table]
        if table_size(orders.draw) > 1 then
            marker_table[index] = {}
            for _, draw_order in pairs(orders.draw) do
                marker_table[index][#marker_table[index] + 1] = rendering[draw_order.type](draw_order)
                counter = counter + 1
            end
        else
            marker_table[index] = rendering[orders.draw[1].type](orders.draw[1])
            counter = counter + 1
        end
        queue[index] = nil
        if counter >= MAX then
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
    if pdata[table_name] and next(pdata[table_name]) then
        if global.highlight_queue and not next(global.highlight_queue) then
            local token = remote.call("PickerAtheneum","queue_add",{mod_name = "PickerBeltTools_highlight"})
            global.queue_token = token
            Event.register(token, highlight_handler, nil, nil, setup.tick_options)
            --Event.register(defines.events.on_tick, highlight_handler, nil, nil, setup.tick_options)
        end
        global.highlight_queue[#global.highlight_queue + 1] = pdata[table_name]
        pdata[table_name] = nil
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

return add_to_highlight_queue
