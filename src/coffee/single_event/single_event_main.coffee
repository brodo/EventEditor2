createSidebar = require('./sidebar.coffee')
eplGenerator = require('./eplGenerator.coffee')
eplReader = require('./eplReader.coffee')
event = require('./event.coffee')
pattern = require('./pattern.coffee')
RestClient = require('../rest_client')
template = require('../../templates/event')
mainDiv = document.querySelector('#main')
eventsRestClient = new RestClient(config.eventsBaseUrl,
  config.eventsCollectionUrl, 
  config.eventsItemUrl,
  csrfToken)

createEvent = null
createPattern = null
getEplField = -> document.querySelector('#eplOutput')

module.exports = (id)->

  window.eventList = []
  window.patternList = []
  window.connectionList = []
  mainDiv.innerHTML = template()
  eventWindow = require('./event_window.coffee')(eventList, connectionList, ->
    enter()
    exit()
    update()
  )

  update = ->
    eplStr = eplGenerator(eventList, connectionList)
    if not (getEplField() == document.activeElement) then getEplField().value = eplStr
    eventWindow.update(eventList)


  enter = ->
    eplStr = eplGenerator(eventList, connectionList)
    if not (getEplField() == document.activeElement) then getEplField().value = eplStr
    eventWindow.enter()

  exit = ->
    eplStr = eplGenerator(eventList, connectionList)
    if not (getEplField() == document.activeElement) then getEplField().value = eplStr
    eventWindow.exit(eventList)
    d3.selectAll('.connector').data(connectionList, (d)-> d.id).exit().remove()

  addEvent = (d,x,y, relative) ->
    event = createEvent(d.name, x, y, false)
    eventList.push(event) 
    enter()
    update()

  addPattern = (d, x, y, realative) ->
    pattern = createPattern(d.name, x,y ,false)
    patternList.push(pattern)
    enter()
    update()

  addSaveButtonListener = ->
    button = document.querySelector('.saveButton')
    button.onclick = -> 
      eplStr = eplGenerator(eventList, connectionList)
      eventsRestClient.updateItem(id, definition: eplStr)


  getMainRect = ->
    d3.select('#svgMain').node().getBoundingClientRect()

  main = (sensors, patterns, savedEvent)->
    addSaveButtonListener()
    epl = savedEvent.definition
    enter()
    createSidebar(addEvent, addPattern ,sensors,patterns)
    createEvent = event(sensors, eventWindow.measures, getMainRect)
    createPattern = pattern(patterns, eventWindow.measures, getMainRect)
    read = eplReader(createEvent, eventList, connectionList)
    eplChanged = ->
      read(getEplField().value)
      exit()
      enter()
      update()
    getEplField().value = epl
    getEplField().oninput = eplChanged
    eplChanged() 

  d3.json(config.sensorsPath, (err, sensors)->
    d3.json(config.patternsPath, (err, patterns)->
      eventsRestClient.getItem(id, (savedEvent)->  
        main(sensors, patterns, savedEvent)
      )
    )
  )

    
