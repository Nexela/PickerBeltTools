local Data = require('__stdlib__/stdlib/data/data')

Data{type = 'custom-input', name = 'picker-wire-picker', key_sequence = 'SHIFT + Q'}

if settings.startup['picker-tool-wire-cutter'].value then
    Data{
        type = 'selection-tool',
        name = 'picker-wire-cutter',
        icon = '__PickerExtended__/graphics/cord-cutter.png',
        icon_size = 64,
        flags = {'hidden', 'only-in-cursor'},
        subgroup = 'tool',
        order = 'c[selection-tool]-a[wire-cutter]',
        stack_size = 1,
        selection_color = {r = 1, g = 0, b = 0},
        alt_selection_color = {r = 0, g = 1, b = 0},
        selection_mode = {'same-force', 'buildable-type', 'items-to-place'},
        alt_selection_mode = {'same-force', 'buildable-type', 'items-to-place'},
        selection_cursor_box_type = 'copy',
        alt_selection_cursor_box_type = 'copy',
        always_include_tiles = false
    }
end

if settings.startup['picker-tool-rewire'].value then
    Data{
        type = 'selection-tool',
        name = 'picker-rewire',
        icon = '__PickerExtended__/graphics/rewire-tool.png',
        icon_size = 32,
        flags = {'hidden', 'only-in-cursor'},
        subgroup = 'tool',
        order = 'c[selection-tool]-a[wire-cutter]',
        stack_size = 1,
        selection_color = {r = 1, g = 0, b = 0},
        alt_selection_color = {r = 0, g = 1, b = 0},
        selection_mode = {'same-force', 'buildable-type', 'items-to-place'},
        alt_selection_mode = {'same-force', 'buildable-type', 'items-to-place'},
        selection_cursor_box_type = 'copy',
        alt_selection_cursor_box_type = 'copy',
        always_include_tiles = false
    }
end
