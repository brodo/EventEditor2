d3 = require('d3')
sidebar = (addEvent, addPattern, sensors, patterns) ->
 
  createDragStart = (rectFunction, cls) -> (d,i ) ->
    rect = rectFunction(i)
    d3.select('#sidebar').append('div')
      .attr('class', "#{cls} dragging")
      .style('position', 'absolute')
      .style('left', "#{rect.left}px")
      .style('top', "#{rect.top}px")
      .text(()-> d.displayName)

  dragmove = (d) ->
    d3.select('.dragging')
      .style('left', "#{d3.event.x}px")
      .style('top', "#{d3.event.y}px")
  
  dragstop = (addFun) -> (d, i)->
    d3.select('.dragging').remove()
    source = d3.event.sourceEvent
    element = document.elementFromPoint(source.clientX, source.clientY)
    if element != null and element.id == "svgMain" then addFun(d, source.clientX,source.clientY,false)
  
  eventDrag = d3.behavior.drag()
    .origin(_.identity)
    .on("drag", dragmove)
    .on("dragstart", createDragStart(getRectForSensorIndex, "eventType"))
    .on("dragend", dragstop(addEvent))

  patternDrag = d3.behavior.drag()
    .origin(_.identity)
    .on("drag", dragmove)
    .on("dragstart", createDragStart(getRectForPatternIndex, "patternType"))
    .on("dragend", dragstop(addPattern))
  
  d3.select('#sidebar').selectAll('.eventType').data(sensors).enter()
    .append('div')
      .attr('class', 'eventType')
      .attr('id', (d,i)-> "eventType-#{i}")
      .text((d)-> d.displayName)
      .call(eventDrag)
  
  d3.select('#sidebar').selectAll('.patternType').data(patterns).enter()
    .append('div')
    .attr('class', 'patternType')
    .attr('id', (d,i) -> "patternType-#{i}")
    .text((d)-> d.displayName)
    .call(patternDrag)

  d3.selectAll('.eventType').each((d,i)->
    rect = getRectForSensorIndex(i)
    d.x = rect.left
    d.y = rect.top
  )

  d3.selectAll('.patternType').each((d,i)->
    rect = getRectForPatternIndex(i)
    d.x = rect.left
    d.y = rect.top
  )



getRectForSensorIndex = (index) ->
  currentElement = d3.select("#eventType-#{index}").node()
  currentElement.getBoundingClientRect()

getRectForPatternIndex = (index) ->
  currentElement = d3.select("#patternType-#{index}").node()
  currentElement.getBoundingClientRect()


module.exports = sidebar