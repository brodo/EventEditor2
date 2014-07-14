createSidebar = require('./sidebar.coffee')
eplGenerator = require('./eplGenerator.coffee')
eplReader = require('./eplReader.coffee')
event = require('./event.coffee')
RestClient = require('../rest_client')
template = require('../../templates/event')
mainDiv = document.querySelector('#main')
config = require('../../data/test_config.json')
eventsRestClient = new RestClient(config.eventsBaseUrl,
  config.eventsCollectionUrl, 
  config.eventsItemUrl,
  csrfToken)

createEvent = null
getEplField = -> document.querySelector('#eplOutput')
module.exports = (id)->
  window.eventList = []
  window.connectionList = []
  mainDiv.innerHTML = template()
  eventWindow = require('./event_window.coffee')(eventList, connectionList, ->
    enter()
    exit()
    update()
  )

  update = ->
    if not (getEplField() == document.activeElement) then getEplField().value = eplGenerator(eventList, connectionList)
    eventWindow.update(eventList)


  enter = ->
    if not (getEplField() == document.activeElement) then getEplField().value = eplGenerator(eventList, connectionList)
    eventWindow.enter()

  exit = ->
    if not (getEplField() == document.activeElement) then getEplField().value = eplGenerator(eventList, connectionList)
    eventWindow.exit(eventList)
    d3.selectAll('.connector').data(connectionList, (d)-> d.id).exit().remove()

  addEvent = (d,x,y, relative)->
    event = createEvent(d.name, x, y, false)
    eventList.push(event) 
    enter()
    update()

  getMainRect = ->
    d3.select('#svgMain').node().getBoundingClientRect()

  d3.json("data/sensors.json", (err, sensors)->
    eventsRestClient.getItem(id, (result)->
      epl = JSON.parse(result).definition
      enter()
      createSidebar(addEvent, sensors)
      createEvent = event(sensors, eventWindow.measures, getMainRect)
      read = eplReader(createEvent, eventList, connectionList)
      eplChanged = ->
        read(getEplField().value)
        exit()
        enter()
        update()
      getEplField().value = epl
      getEplField().oninput = eplChanged
      eplChanged()
    )
  )

    
