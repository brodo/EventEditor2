d3 = require('d3')
createSidebar = require('./sidebar.coffee')
_ = require('lodash')
eplGenerator = require('./eplGenerator.coffee')
eplReader = require('./eplReader.coffee')
event = require('./event.coffee')
createEvent = null
window.eventList = []
window.connectionList = []
window.d3 = d3
window._ = _
eplField = document.querySelector('#eplOutput')




eventWindow = require('./event_window.coffee')(eventList, connectionList, ->
  enter()
  exit()
  update()
)

update = ->
  if not (eplField == document.activeElement) then eplField.value = eplGenerator(eventList, connectionList)
  eventWindow.update(eventList)


enter = ->
  if not (eplField == document.activeElement) then eplField.value = eplGenerator(eventList, connectionList)
  eventWindow.enter()

exit = ->
  if not (eplField == document.activeElement) then eplField.value = eplGenerator(eventList, connectionList)
  eventWindow.exit(eventList)
  d3.selectAll('.connector').data(connectionList, (d)-> d.id).exit().remove()

addEvent = (d,x,y)->
  event = createEvent(d.name, x, y)
  eventList.push(event) 
  enter()
  update()

getMainRect = ->
  d3.select('#svgMain').node().getBoundingClientRect()
    
enter()

d3.json("data/sensors.json", (err, sensors)->
  createSidebar(addEvent, sensors)
  createEvent = event(sensors, eventWindow.measures, getMainRect)
  read = eplReader(createEvent, eventList, connectionList)
  eplField.oninput = ->
    read(eplField.value)
    exit()
    enter()
    update()
)