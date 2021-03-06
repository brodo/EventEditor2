createSidebar = require('./sidebar.coffee')
eplGenerator = require('./eplGenerator.coffee')
eplReader = require('./eplReader.coffee')
event = require('./event.coffee')
pattern = require('./pattern.coffee')
RestClient = require('../rest_client')
template = require('../../templates/event')
mainDiv = document.querySelector('#event-main')
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
  windows = require('./windows.coffee')(eventList, patternList, connectionList, ->
    enter()
    exit()
    update()
  )

  update = ->
    eplStr = eplGenerator(eventList, patternList, connectionList)
    if not (getEplField() == document.activeElement) then getEplField().value = eplStr
    windows.update(eventList)


  enter = ->
    eplStr = eplGenerator(eventList, patternList, connectionList)
    if not (getEplField() == document.activeElement) then getEplField().value = eplStr
    windows.enter()

  exit = ->
    eplStr = eplGenerator(eventList, patternList, connectionList)
    if not (getEplField() == document.activeElement) then getEplField().value = eplStr
    windows.exit(eventList)
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
      eplStr = eplGenerator(eventList, patternList, connectionList)
      eventsRestClient.updateItem(id, definition: eplStr)


  getMainRect = ->
    d3.select('#svgMain').node().getBoundingClientRect()

  main = (sensors, patterns, savedEvent)->
    addSaveButtonListener()
    epl = savedEvent.definition
    enter()
    createSidebar(addEvent, addPattern ,sensors,patterns)
    createEvent = event(sensors, windows.measures, getMainRect)
    createPattern = pattern(patterns, windows.measures, getMainRect)
    read = eplReader(createEvent, createPattern, eventList, patternList, connectionList)
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

    
