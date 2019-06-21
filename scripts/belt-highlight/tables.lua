local Event = require('__stdlib__/stdlib/event/event')
local Position = require('__stdlib__/stdlib/area/position')
local tables = {}

tables.tick_options = {
    skip_valid = true,
    protected_mode = false
}

tables.protected = {
    protected_mode = Event.options.protected_mode,
    skip_valid = true
}
tables.empty = {}

tables.allowed_types = {
    ['underground-belt'] = true,
    ['transport-belt'] = true,
    ['splitter'] = true
}
tables.marker_entry = {
    [0] = 1,
    [1] = 2,
    [4] = 3,
    [5] = 4,
    [16] = 5,
    [17] = 6,
    [20] = 7,
    [21] = 8,
    [64] = 9,
    [65] = 10,
    [68] = 11,
    [69] = 12,
    [80] = 13,
    [81] = 14,
    [84] = 15,
    [85] = 16
}

tables.bitwise_marker_entry = {
    [0x00] = 1,
    [0x01] = 2,
    [0x04] = 3,
    [0x05] = 4,
    [0x10] = 5,
    [0x11] = 6,
    [0x14] = 7,
    [0x15] = 8,
    [0x40] = 9,
    [0x41] = 10,
    [0x44] = 11,
    [0x45] = 12,
    [0x50] = 13,
    [0x51] = 14,
    [0x54] = 15,
    [0x55] = 16
}

do
    local north = {
        left = Position(-0.4, -0.75),
        right = Position(0.4, -0.75),
        rev_left = Position(-0.4, 0.75),
        rev_right = Position(0.4, 0.75)
    }
    local east = {
        left = -north.right:swap(),
        right = -north.left:swap(),
        rev_left = -north.rev_right:swap(),
        rev_right = -north.rev_left:swap()
    }
    local south = {
        left = -north.left,
        right = -north.right,
        rev_left = -north.rev_left,
        rev_right = -north.rev_right
    }
    local west = {
        left = -east.left,
        right = -east.right,
        rev_left = -east.rev_left,
        rev_right = -east.rev_right
    }
    tables.ug_offsets = {
        [defines.direction.north] = north,
        [defines.direction.east] = east,
        [defines.direction.south] = south,
        [defines.direction.west] = west
    }
end

do
    local north = {
        left = Position(-0.5, -1),
        right = Position(0.5, -1)
    }
    local east = {
        left = -north.right:swap(),
        right = -north.left:swap()
    }
    local south = {
        left = -north.left,
        right = -north.right
    }
    local west = {
        left = -east.left,
        right = -east.right
    }
    tables.splitter_offsets = {
        [defines.direction.north] = north,
        [defines.direction.east] = east,
        [defines.direction.south] = south,
        [defines.direction.west] = west
    }
end

return tables
