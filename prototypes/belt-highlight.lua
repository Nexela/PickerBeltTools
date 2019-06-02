data:extend {
    {
        type = 'custom-input',
        name = 'picker-show-underground-belt-paths',
        key_sequence = 'CONTROL + SHIFT + U',
        consuming = 'script-only'
    }
}

local base_entity = {
    type = 'simple-entity',
    name = 'fillerstuff',
    flags = {'placeable-neutral', 'not-on-map', 'placeable-off-grid'},
    subgroup = 'remnants',
    order = 'd[remnants]-c[wall]',
    icon = '__PickerBeltTools__/graphics/entity/markers/32x32highlightergood.png',
    icon_size = 32,
    --time_before_removed = 2000000000,
    collision_box = {{0, 0}, {0, 0}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    collision_mask = {'layer-14'},
    selectable_in_game = false
    --final_render_layer = 'selection-box',
    --[[
        animations = {
            {
        width = 64,
        height = 64,
        line_length = 8,
        frame_count = 16,
        direction_count = 1,
        animation_speed = 0.03125 * 16,
        scale = 0.5,
        filename = '__PickerBeltTools__/graphics/entity/markers/32x32highlightergood.png'
            }
        }
    --]]
}

local belt_pictures = {}
local belt_sprite_prototypes = {}
for i = 1, 64 do
    local y = 0
    if i > 16 and i <= 32 then
        y = 32
    elseif i > 32 and i <= 48 then
        y = 64
    elseif i > 48 and i <= 64 then
        y = 96
    end
    belt_pictures[i] = {
        width = 32,
        height = 32,
        x = ((i - 1) % 16) * 32,
        y = y,
        line_length = 16,
        frame_count = 1,
        direction_count = 1,
        --scale = 0.5,
        --shift = {-0.5,-0.5},
        filename = '__PickerBeltTools__/graphics/entity/markers/belt-arrow-set-full.png'
    }
    belt_sprite_prototypes[i] = {
        type = "sprite",
        name = "picker-belt-marker-" .. i,
        width = 32,
        height = 32,
        x = ((i - 1) % 16) * 32,
        y = y,
        line_length = 16,
        frame_count = 1,
        direction_count = 1,
        --scale = 0.5,
        --shift = {-0.5,-0.5},
        filename = '__PickerBeltTools__/graphics/entity/markers/belt-arrow-set-full.png'
    }
end

local belt_marker = util.table.deepcopy(base_entity)
belt_marker.name = 'picker-belt-marker-full'
belt_marker.pictures = belt_pictures

data:extend({belt_marker})
data:extend(belt_sprite_prototypes)

local splitter_image_table = {
    {
        image = 'splitter-marker-north',
        index_multiplier = 1,
        image_size = {
            x = 64,
            y = 32
        },
        selection_box = {
            {-1, -0.5},
            {1, 0.5}
        }
    },
    {
        image = 'splitter-marker-east',
        index_multiplier = 2,
        image_size = {
            x = 32,
            y = 64
        },
        selection_box = {
            {-0.5, -1},
            {0.5, 1}
        }
    },
    {
        image = 'splitter-marker-south',
        index_multiplier = 3,
        image_size = {
            x = 64,
            y = 32
        },
        selection_box = {
            {-1, -0.5},
            {1, 0.5}
        }
    },
    {
        image = 'splitter-marker-west',
        index_multiplier = 4,
        image_size = {
            x = 32,
            y = 64
        },
        selection_box = {
            {-0.5, -1},
            {0.5, 1}
        }
    }
}

local splitter_markers = {}
local splitter_sprite_prototypes = {}
for _, image_data in pairs(splitter_image_table) do
    local splitter_pictures = {}
    --local counter = 1
    local splitter_marker = util.table.deepcopy(base_entity)
    for i = 1, 16 do
        local y = 0 * image_data.image_size.y
        if i > 4 and i <= 8 then
            y = 1 * image_data.image_size.y
        elseif i > 8 and i <= 12 then
            y = 2 * image_data.image_size.y
        elseif i > 12 and i <= 16 then
            y = 3 * image_data.image_size.y
        end
        splitter_pictures[i] = {
            width = image_data.image_size.x,
            height = image_data.image_size.y,
            x = ((i - 1) % 4) * image_data.image_size.x,
            y = y,
            line_length = 4,
            frame_count = 1,
            direction_count = 1,
            --scale = 0.5,
            --shift = {-0.5,-0.5},
            filename = '__PickerBeltTools__/graphics/entity/markers/' .. image_data.image .. '.png'
        }
        --counter = counter + 1
    end
    splitter_marker.name = 'picker-' .. image_data.image
    splitter_marker.pictures = splitter_pictures
    splitter_marker.selection_box = image_data.selection_box
    splitter_markers[#splitter_markers + 1] = splitter_marker

    --local splitter_sprite_prototypes = {}
    --local counter = 1
    --local splitter_marker = util.table.deepcopy(base_entity)
    for i = 1, 16 do
        local y = 0 * image_data.image_size.y
        if i > 4 and i <= 8 then
            y = 1 * image_data.image_size.y
        elseif i > 8 and i <= 12 then
            y = 2 * image_data.image_size.y
        elseif i > 12 and i <= 16 then
            y = 3 * image_data.image_size.y
        end
        splitter_sprite_prototypes[#splitter_sprite_prototypes + 1] = {
            type = "sprite",
            name = 'picker-' .. image_data.image .. "-" .. i,
            width = image_data.image_size.x,
            height = image_data.image_size.y,
            x = ((i - 1) % 4) * image_data.image_size.x,
            y = y,
            line_length = 4,
            frame_count = 1,
            direction_count = 1,
            --scale = 0.5,
            --shift = {-0.5,-0.5},
            filename = '__PickerBeltTools__/graphics/entity/markers/' .. image_data.image .. '.png'
        }
        --counter = counter + 1
    end
    --splitter_marker.pictures = splitter_pictures
    --splitter_marker.selection_box = image_data.selection_box
    --splitter_markers[#splitter_markers + 1] = splitter_marker
end

data:extend(splitter_markers)
data:extend(splitter_sprite_prototypes)

local ug_belt_pictures = {}
local ug_belt_sprite_prototypes = {}
for i = 1, 64 do
    local y = 0
    if i > 16 and i <= 32 then
        y = 32
    elseif i > 32 and i <= 48 then
        y = 64
    elseif i > 48 and i <= 64 then
        y = 96
    end
    ug_belt_pictures[i] = {
        layers = {
            {
                width = 32,
                height = 32,
                x = ((i - 1) % 16) * 32,
                y = y,
                line_length = 16,
                frame_count = 1,
                direction_count = 1,
                --scale = 0.5,
                --shift = {-0.5,-0.5},
                filename = '__PickerBeltTools__/graphics/entity/markers/belt-arrow-set-full.png'
            },
            {
                width = 64,
                height = 64,
                x = 0,
                line_length = 5,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                --shift = {-0.5,-0.5},
                filename = '__core__/graphics/cursor-boxes-32x32.png'
            }
        }
    }

    ug_belt_sprite_prototypes[i] = {
        type = "sprite",
        name = "picker-ug-belt-marker-" .. i,
        layers = {
            {
                width = 32,
                height = 32,
                x = ((i - 1) % 16) * 32,
                y = y,
                line_length = 16,
                frame_count = 1,
                direction_count = 1,
                --scale = 0.5,
                --shift = {-0.5,-0.5},
                filename = '__PickerBeltTools__/graphics/entity/markers/belt-arrow-set-full.png'
            },
            {
                width = 64,
                height = 64,
                x = 0,
                line_length = 5,
                frame_count = 1,
                direction_count = 1,
                scale = 0.5,
                --shift = {-0.5,-0.5},
                filename = '__core__/graphics/cursor-boxes-32x32.png'
            }
        }
    }
end

local ug_belt_marker = util.table.deepcopy(base_entity)
ug_belt_marker.name = 'picker-ug-belt-marker-full'
ug_belt_marker.pictures = ug_belt_pictures

data:extend({ug_belt_marker})
data:extend(ug_belt_sprite_prototypes)

--[[
    local belt_marker_table = {
    ['picker-belt-marker-straight-both-lanes'] = 'belt-animated-both-lane',
    --['picker-pump-marker-good'] = 'pump-marker-good'
}
local belt_directions = {
    '-n',
    '-e',
    '-s',
    '-w'
}

local new_markers = {}
for belt_marker_name, images in pairs(belt_marker_table) do
    for _, directions in pairs(belt_directions) do
        local current_entity = util.table.deepcopy(base_entity)
        current_entity.type = 'simple-entity'
        current_entity.name = belt_marker_name .. directions
        --current_entity.animation.shift = {0, -0.1}
        current_entity.animations[1].filename = '__PickerBeltTools__/graphics/entity/markers/' .. images .. directions .. '.png'
        new_markers[#new_markers + 1] = current_entity
    end
end

for _, stuff in pairs(new_markers) do
    data:extend {
        merge {
            base_entity,
            stuff
        }
    }
end
--]]
local base_beam = util.table.deepcopy(data.raw['beam']['electric-beam-no-sound'])
base_beam.name = 'picker-underground-belt-marker-beam'
base_beam.width = 1.0
base_beam.damage_interval = 2000000000
base_beam.action = nil
base_beam.start = {
    filename = '__PickerBeltTools__/graphics/empty_1x16.png',
    line_length = 1,
    width = 1,
    height = 1,
    frame_count = 16,
    axially_symmetrical = false,
    direction_count = 1,
    hr_version = {
        filename = '__PickerBeltTools__/graphics/empty_1x16.png',
        line_length = 1,
        width = 1,
        height = 1,
        frame_count = 16,
        axially_symmetrical = false,
        direction_count = 1
    }
}
base_beam.ending = {
    filename = '__PickerBeltTools__/graphics/empty_1x16.png',
    line_length = 1,
    width = 1,
    height = 1,
    frame_count = 16,
    axially_symmetrical = false,
    direction_count = 1,
    hr_version = {
        filename = '__PickerBeltTools__/graphics/empty_1x16.png',
        line_length = 1,
        width = 1,
        height = 1,
        frame_count = 16,
        axially_symmetrical = false,
        direction_count = 1
    }
}
--[[
base_beam.ending = {
    filename = '__PickerBeltTools__/graphics/entity/markers/' .. marker_name.box .. '.png',
    line_length = 1,
    width = 64,
    height = 64,
    frame_count = 1,
    axially_symmetrical = false,
    direction_count = 1,
    --shift = {-0.03125, 0},
    scale = 0.5,
    hr_version = {
        filename = '__PickerBeltTools__/graphics/entity/markers/' .. marker_name.box .. '.png',
        line_length = 1,
        width = 64,
        height = 64,
        frame_count = 1,
        axially_symmetrical = false,
        direction_count = 1,
        --shift = {0.53125, 0},
        scale = 0.5
    }
}
--]]
base_beam.head = {
    filename = '__PickerBeltTools__/graphics/entity/markers/underground-lines-animated.png',
    flags = {'no-crop'},
    line_length = 8,
    width = 64,
    height = 64,
    frame_count = 16,
    animation_speed = 0.03125 * 16,
    scale = 0.5
}
base_beam.tail = {
    filename = '__PickerBeltTools__/graphics/entity/markers/underground-lines-animated.png',
    flags = {'no-crop'},
    line_length = 8,
    width = 64,
    height = 64,
    frame_count = 16,
    animation_speed = 0.03125 * 16,
    scale = 0.5
}
base_beam.body = {
    {
        filename = '__PickerBeltTools__/graphics/entity/markers/underground-lines-animated.png',
        flags = {'no-crop'},
        line_length = 8,
        width = 64,
        height = 64,
        frame_count = 16,
        animation_speed = 0.03125 * 16,
        scale = 0.5
    }
}
--[[
local underground_marker_beams = {}
for _,belt in pairs(data.raw['underground-belt']) do
    local current_beam = _G.util.table.deepcopy(base_beam)
    current_beam.name = belt.name .. "-underground-marker-beam"
    current_beam.head.animation_speed = belt.speed * belt.belt_horizontal.frame_count
    current_beam.tail.animation_speed = belt.speed * belt.belt_horizontal.frame_count
    current_beam.body[1].animation_speed = belt.speed * belt.belt_horizontal.frame_count
    underground_marker_beams[#underground_marker_beams + 1] = current_beam
end
--]]
data:extend({base_beam})
