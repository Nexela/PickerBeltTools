local Data = require('__stdlib__/stdlib/data/data')

Data {
    type = 'custom-input',
    name = 'picker-show-underground-belt-paths',
    key_sequence = 'CONTROL + SHIFT + U',
    consuming = 'script-only'
}

Data {
    type = 'shortcut',
    name = 'picker-belt-highlighter',
    action = 'lua',
    toggleable = true,
    icon = {
        filename = '__PickerBeltTools__/graphics/icons/belt-marker-shortcut.png',
        priority = 'extra-high-no-scale',
        size = 32,
        scale = 1,
        flags = {'icon'}
    }
}

local belt_marker_box = {}
belt_marker_box[#belt_marker_box + 1] = {
    type = 'sprite',
    name = 'picker-belt-marker-box-good',
    width = 64,
    height = 64,
    x = 192,
    y = 0,
    scale = 0.5,
    filename = '__core__/graphics/cursor-boxes-32x32.png'
}
belt_marker_box[#belt_marker_box + 1] = {
    type = 'sprite',
    name = 'picker-belt-marker-box-bad',
    width = 64,
    height = 64,
    x = 64,
    y = 0,
    scale = 0.5,
    filename = '__core__/graphics/cursor-boxes-32x32.png'
}


local belt_sprite_prototypes = {}
do
    local i = 1
    --for y = 0, 128 - 32, 32 do
        for x = 0, 512 - 32, 32 do
            belt_sprite_prototypes[i] = {
                type = 'sprite',
                name = 'picker-belt-marker-' .. i,
                width = 32,
                height = 32,
                x = x,
                y = 0,
                filename = '__PickerBeltTools__/graphics/entity/markers/belt-arrows.png'
            }
            i = i + 1
        end
    --end
end

local splitter_table = {
    ['splitter-markers'] = {
        size = {x = 64, y = 32},
        width = {x = 256, y = 128}
    },
    --['splitter-marker-east'] = {
    --    size = {x = 32, y = 64},
    --    width = {x = 128, y = 256}
    --},
    --['splitter-marker-south'] = {
    --    size = {x = 64, y = 32},
    --    width = {x = 256, y = 128}
    --},
    --['splitter-marker-west'] = {
    --    size = {x = 32, y = 64},
    --    width = {x = 128, y = 256}
    --}
}

local splitter_sprite_prototypes = {}
do
    for name, data in pairs(splitter_table) do
        local i = 1
        for y = 0, data.width.y - data.size.y, data.size.y do
            for x = 0, data.width.x - data.size.x, data.size.x do
                splitter_sprite_prototypes[#splitter_sprite_prototypes + 1] = {
                    type = 'sprite',
                    name = 'picker-' .. name .. '-' .. i,
                    width = data.size.x,
                    height = data.size.y,
                    x = x,
                    y = y,
                    filename = '__PickerBeltTools__/graphics/entity/markers/' .. name .. '.png'
                }
                i = i + 1
            end
        end
    end
end

local ug_belt_sprite_prototypes = {}
do
    local i = 1
    --for y = 0, 128 - 32, 32 do
        for x = 0, 512 - 32, 32 do
            ug_belt_sprite_prototypes[i] = {
                type = 'sprite',
                name = 'picker-ug-belt-marker-' .. i,
                layers = {
                    {
                        width = 32,
                        height = 32,
                        x = x,
                        y = 0,
                        filename = '__PickerBeltTools__/graphics/entity/markers/belt-arrows.png'
                    },
                    {
                        width = 64,
                        height = 64,
                        x = 0,
                        scale = 0.5,
                        filename = '__core__/graphics/cursor-boxes-32x32.png'
                    }
                }
            }
            i = i + 1
        end
    --end
end

data:extend(belt_sprite_prototypes)
data:extend(splitter_sprite_prototypes)
data:extend(ug_belt_sprite_prototypes)
data:extend(belt_marker_box)
