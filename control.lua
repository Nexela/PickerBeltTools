local Event = require('__stdlib__/event/event')
Event.protected_mode = false

local Player = require('__stdlib__/event/player').register_events()
local Force = require('__stdlib__/event/force').register_events()

local function on_init()
    Player.init()
    Force.init()
end
Event.register(Event.core_events.init, on_init)

--(( Load Scripts ))--
require('scripts/beltbrush')
require('scripts/beltreverser')
require('scripts/orphans')
require('scripts/pipehighlight')
require('scripts/pipecleaner')
--)) Load Scripts ((--

remote.add_interface(script.mod_name, require('__PickerExtended__/interface'))
