d3 = require('d3')
createSidebar = require('./sidebar.js')
_ = require('lodash')
window.eventList = []
window.connectionList = []
window.d3 = d3
window._ = _
eventCount = 0

eventWindow = require('./event_window.js')(eventList, connectionList, ->
  enter()
  exit()
  update()
)

connectorLine = d3.svg.line().x((d)-> d.x).y((d)->d.y).interpolate('linear')

dragConnector =  d3.behavior.drag()
  .origin((d)-> d.nodes[1])
  .on("drag", (d)->
    d.nodes[1].x = Math.max(0, d3.event.x)
    d.nodes[1].y = Math.max(0, d3.event.y)
    d.middleHasBeenDragged = true
    d3.select(@.parentElement).moveToFront()
    update()
  )

update = ->
  eventWindow.update(eventList)
  connectionList.forEach((e)-> 
    [start, middle, end] = e.nodes
    source = eventList[e.source]
    if e.type == "and"
      start.x = source.andRectMiddle().x
      start.y = source.andRectMiddle().y
    else
      start.x = source.followedByRectMiddle().x
      start.y = source.followedByRectMiddle().y
    if not e.middleHasBeenDragged
      newMiddle = d3.interpolateObject(start, end)(0.5)
      middle.x = newMiddle.x
      middle.y = newMiddle.y
    if (typeof e.target) != 'undefined' and e.target != null
      target = eventList[e.target]
      if e.type == "and"
        end.x = target.andRectMiddle().x
        end.y = target.andRectMiddle().y
      else
        end.x = target.followedByRectMiddle().x
        end.y = target.followedByRectMiddle().y
  )

  d3.selectAll('.connectorPath').data(connectionList, (d)-> d.id)
    .attr('d', (d) -> connectorLine(d.nodes))
  
  d3.selectAll('.connectorCircle').data(connectionList, (d)-> d.id)
    .attr('cx', (d)-> d.nodes[1].x)
    .attr('cy', (d)-> d.nodes[1].y)
  
  d3.selectAll('.connectorText').data(connectionList, (d)-> d.id)
    .attr('x', (d)-> d.nodes[1].x)
    .attr('y', (d)-> d.nodes[1].y)
    .text((d)-> if d.type == "and" then '⋀' else '→')

enter = ->
  eventWindow.enter(eventList)
  conn = d3.select('#svgMain').selectAll('.connector').data(connectionList, (d)-> d.id)
    .enter().append('g').attr('class', 'connector')
  
  conn.append('path')
    .attr('class', 'connectorPath')
    .attr('stroke', 'black')
    .attr('stroke-width', 3)
    .attr('fill', 'none')
    .attr('d', (d)-> connectorLine(d.nodes))
  
  conn.append('circle')
    .attr('class', 'connectorCircle')
    .attr('cx', (d)-> d.nodes[1].x)
    .attr('cy', (d)-> d.nodes[1].y)
    .attr('r', 20)
    .call(dragConnector)

  conn.append('text')
    .attr('class', 'connectorText')
    .text((d)-> if d.type == "and" then '⋀' else '→')
    .attr('x', (d)-> d.nodes[1].x)
    .attr('y', (d)-> d.nodes[1].y)
    .attr('width', 15)
    .attr('height', 15)
    .call(dragConnector)


exit = ->
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
  data.patternName = "#{data.displayName}##{eventCount}"
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