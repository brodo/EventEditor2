d3 = require('d3')
createSidebar = require('./sidebar.coffee')
_ = require('lodash')
eplGenerator = require('./eplGenerator.coffee')
eplReader = require('./eplReader.coffee')
window.eventList = []
window.connectionList = []
window.d3 = d3
window._ = _
eventCount = 0
eplField = document.querySelector('#eplOutput')


eplField.oninput = ->
  eplReader(eplField.value)


eventWindow = require('./event_window.coffee')(eventList, connectionList, ->
  enter()
  exit()
  update()
)

update = ->
  eplField.value = eplGenerator(eventList, connectionList)
  eventWindow.update(eventList)


enter = ->
  eplField.value = eplGenerator(eventList, connectionList)
  eventWindow.enter()

exit = ->
  eplField.value = eplGenerator(eventList, connectionList)
  eventWindow.exit(eventList)
  d3.selectAll('.connector').data(connectionList, (d)-> d.id).exit().remove()

addEvent = (d,x,y)->
  eventCount++
  data = _.cloneDeep(d)
  data.id = Date.now()
  data.x = Math.max(0,x-getMainRect().left-125)
  data.y  = Math.max(0,y-getMainRect().top-125)
  data.width = eventWindow.measures.eventWidth
  data.height = eventWindow.measures.eventWidth 
  data.patternName = "#{data.displayName}#{eventCount}"
  data.andRect = -> 
    x: @x + 5
    y: @y + @height - eventWindow.measures.eventTitleHeight + 5
  data.andRectMiddle = ->
    x: @andRect().x + eventWindow.measures.andCombinatorButtonWidth / 2
    y: @andRect().y + eventWindow.measures.andCombinatorButtonHeight / 2
  data.followedByRect = -> 
    x: @x + 5 + eventWindow.measures.andCombinatorButtonWidth + 5
    y: @y + @height - eventWindow.measures.eventTitleHeight + 5
  data.followedByRectMiddle = ->
    x: @followedByRect().x + eventWindow.measures.followedByCombinatorButtonWidth / 2
    y: @followedByRect().y + eventWindow.measures.followedByCombinatorButtonHeight / 2
  data.nameContainer = ->
    x: @x + 10
    y: @y + @height - eventWindow.measures.eventNameHeight - eventWindow.measures.eventBottomBarHeight

  for parameter in data.parameters
    parameter.conditions = []
    parameter.parentId = data.id
  eventList.push(data) 
  enter()
  update()

getMainRect = ->
  d3.select('#svgMain').node().getBoundingClientRect()
    
enter()
d3.json("data/sensors.json", createSidebar(addEvent))