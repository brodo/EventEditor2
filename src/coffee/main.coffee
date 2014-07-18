meta = document.querySelector('meta[name="csrf-token"]')
window.csrfToken = if meta then meta.content else "t1jpiODT3yO/Gatbgu+tKj1HiYMn02b+lejnbFlmc5c="
window.d3 = require('d3')
window._ = require('lodash')
window.config = require('../data/test_config.json')

event_list = require('./event_list/events_list_main')
event = require('./single_event/single_event_main')

console.clear()

navigate = ->
  if location.hash == "" # List view
    event_list()
  else # item view
    event(location.hash[1..])


window.onhashchange = navigate

navigate()