d3 = require('d3')
createSidebar = require('./sidebar.js')
_ = require('lodash')
eventList = []
connectionList = []
eventWindow = require('./event_window.js')(eventList, connectionList)
connectorLine = d3.svg.line().x((d)-> d.x).y((d)->d.y).interpolate('basis')



update = ->
  eventWindow.update(eventList)
  d3.select('#svgMain').selectAll('.connector').data(connectionList)
    .attr('d', (d) -> 
      # target = if d.target != null 
      #   eventList[d.target].andRect() 
      # else 
      #   _.last(d.nodes)
      # target.fixed = true
      connectorLine(d.nodes)
    )


enter = ->
  eventWindow.enter(eventList)
  d3.select('#svgMain').selectAll('.connector').data(connectionList).enter()
    .append('path')
      .attr('class', 'connector')
      .attr('stroke', 'black')
      .attr('stroke-width', 3)
      .attr('fill', 'none')
      .attr('d', (d) -> 
        connectorLine(d.nodes)
      )
  d3.select('#svgMain').selectAll('.connector').data(connectionList).enter()
    .append('circle')
    .attr('cx', (d)-> d.nodes[1].x)
    .attr('cy', (d)-> d.nodes[1].y)
    .attr('r', 15)

exit = ->
  eventWindow.exit(eventList)
  d3.select('#svgMain').selectAll('.connector').data(connectionList).exit().remove()

addEvent = (d,x,y)->
  data = _.cloneDeep(d) 
  data.x = Math.max(0,x-getMainRect().left-125)
  data.y  = Math.max(0,y-getMainRect().top-125)
  data.width = eventWindow.measures.eventWidth
  data.height = eventWindow.measures.eventWidth 
  data.andRect = -> 
    x: @x + 5
    y: @y + @height - eventWindow.measures.eventTitleHeight + 5
  data.andRectMiddle = ->
    x: @andRect().x + eventWindow.measures.combinatorButtonWidth / 2
    y: @andRect().y + eventWindow.measures.combinatorButtonHeight / 2

  eventList.push(data) 
  enter()

  
getMainRect = ->
  d3.select('#svgMain').node().getBoundingClientRect()
    
enter()
d3.json("data/sensors.json", createSidebar(addEvent))