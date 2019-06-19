local Position = require('__stdlib__/stdlib/area/position')

local setup = {}

setup.tick_options = {
    protected_mode = true,
    skip_valid = true
}

setup.map_direction = {
    [0] = 'picker-splitter-marker-north',
    [2] = 'picker-splitter-marker-east',
    [4] = 'picker-splitter-marker-south',
    [6] = 'picker-splitter-marker-west'
}

setup.marker_entry = {
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

setup.bitwise_marker_entry = {
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

setup.ug_marker_table = {
    [defines.direction.north] = {
        left = Position(-0.4, -0.75),
        right = Position(0.4, -0.75),
        rev_left = Position(-0.4, 0.75),
        rev_right = Position(0.4, 0.75)
    },
    [defines.direction.east] = {
        left = Position(0.75, -0.4),
        right = Position(0.75, 0.4),
        rev_left = Position(-0.75, -0.4),
        rev_right = Position(-0.75, 0.4)
    },
    [defines.direction.south] = {
        left = Position(0.4, 0.75),
        right = Position(-0.4, 0.75),
        rev_left = Position(0.4, -0.75),
        rev_right = Position(-0.4, -0.75)
    },
    [defines.direction.west] = {
        left = Position(-0.75, 0.4),
        right = Position(-0.75, -0.4),
        rev_left = Position(0.75, 0.4),
        rev_right = Position(0.75, -0.4)
    }
}

setup.allowed_types = {
    ['underground-belt'] = true,
    ['transport-belt'] = true,
    ['splitter'] = true
}

setup.splitter_check_table = {
    [defines.direction.north] = {
        left = Position(-0.5, -1),
        right = Position(0.5, -1)
    },
    [defines.direction.east] = {
        left = Position(1, -0.5),
        right = Position(1, 0.5)
    },
    [defines.direction.south] = {
        left = Position(0.5, 1),
        right = Position(-0.5, 1)
    },
    [defines.direction.west] = {
        left = Position(-1, 0.5),
        right = Position(-1, -0.5)
    }
}

setup.find_direction_map = {
    [defines.direction.north] = {
        defines.direction.east,
        defines.direction.west,
        defines.direction.south
    },
    [defines.direction.east] = {
        defines.direction.north,
        defines.direction.west,
        defines.direction.south
    },
    [defines.direction.south] = {
        defines.direction.north,
        defines.direction.east,
        defines.direction.west
    },
    [defines.direction.west] = {
        defines.direction.north,
        defines.direction.east,
        defines.direction.south
    }
}
return setup
