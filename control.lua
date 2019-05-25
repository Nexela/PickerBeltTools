require('__stdlib__/stdlib/event/event').protected_mode = true
require('__stdlib__/stdlib/event/player').register_events(true)
require('__stdlib__/stdlib/event/force').register_events(true)

--(( Load Scripts ))--
require('scripts/beltbrush')
require('scripts/beltreverser')
require('scripts/belt-highlight')
--)) Load Scripts ((--

remote.add_interface(script.mod_name, require('__stdlib__/stdlib/scripts/interface'))
