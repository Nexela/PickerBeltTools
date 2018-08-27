local Data = require('__stdlib__/stdlib/data/data')

local pipe = Data('wall-remnants', 'corpse'):copy('pipe-marker-box'):set_fields {
    name = 'pipe-marker-box',
    icon = '__PickerBeltTools__/graphics/32x32highlighter.png',
    time_before_removed = 60 * 20,
    collision_box = {{0, 0}, {0, 0}},
    final_render_layer = 'selection-box',
    animation = {
        width = 64,
        height = 64,
        frame_count = 1,
        direction_count = 1,
        scale = 0.5,
        shift = {-0.5, -0.5},
        filename = '__PickerBeltTools__/graphics/32x32highlighter.png'
    }
}

local hor = pipe:copy('underground-pipe-marker-horizontal')
hor.animation.filename = '__PickerBeltTools__/graphics/underground-lines-single-horizontal.png'
hor.icon = '__PickerBeltTools__/graphics/underground-lines-single-horizontal.png'
local ver = pipe:copy('underground-pipe-marker-vertical')
ver.animation.filename = '__PickerBeltTools__/graphics/underground-lines-single-vertical.png'
ver.icon = '__PickerBeltTools__/graphics/underground-lines-single-vertical.png'
