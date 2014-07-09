d3 = require('d3')
sidebar = (addEvent, sensors) ->
  dragstart = (d,i ) ->
    rect = getRectForSensorIndex(i)
    d3.select('#sidebar').append('div')
      .attr('class', 'eventType dragging')
      .style('position', 'absolute')
      .style('left', "#{rect.left}px")
      .style('top', "#{rect.top}px")
      .text(()-> d.displayName)

  dragmove = (d) ->
    d3.select('.dragging')
      .style('left', "#{d3.event.x}px")
      .style('top', "#{d3.event.y}px")
  
  dragstop = (d, i)->
    d3.select('.dragging').remove()
    source = d3.event.sourceEvent
    element = document.elementFromPoint(source.clientX, source.clientY)
    if element != null and element.id == "svgMain" then addEvent(d, source.clientX,source.clientY)
  
  drag = d3.behavior.drag()
    .origin(id)
    .on("drag", dragmove)
    .on("dragstart", dragstart)
    .on("dragend", dragstop)
  
  d3.select('#sidebar').selectAll('.eventType').data(sensors).enter()
    .append('div')
      .attr('class', 'eventType')
      .attr('id', (d,i)-> "eventType-#{i}")
      .text((d)-> d.displayName)
      .call(drag)
  
  d3.selectAll('.eventType').each((d,i)->
    rect = getRectForSensorIndex(i)
    d.x = rect.left
    d.y = rect.top
  )

getRectForSensorIndex = (index) ->
  currentElement = d3.select("#eventType-#{index}").node()
  currentElement.getBoundingClientRect()
id = (x) -> x
module.exports = sidebar