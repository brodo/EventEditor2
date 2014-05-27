d3 = require('d3')
window.d3 = d3
eventList = []

createEvents = ->
  
  dragmove = (d,i) ->
    d.x = d3.event.x 
    d.y = d3.event.y 
    d3.select(@).attr("x", d.x).attr("y", d.y)
    d3.select("#eventHtml-#{i}").attr("x", d.x+5).attr("y", d.y+30)
  
  drag = d3.behavior.drag()
    .origin(id)
    .on("drag", dragmove)
  
  events = d3.select('#svgMain').selectAll('.event').data(eventList)
  
  events.enter()
    .append('rect')
      .attr('class', 'event')
      .attr('x', (d)-> d.x )
      .attr('y', (d)-> d.y)
      .attr('width', 250)
      .attr('height', 250)
      .attr('rx', "20")
      .attr('ry', "20")
      .call(drag)
      .append('text')
        .attr('x', 0)
        .attr('y', 0)
        .attr('class', 'eventTitle')
        .text((d)-> d.displayName)
  
  eventsHtml = d3.select('#svgMain').selectAll('.eventHtml').data(eventList)
  innerDiv = eventsHtml.enter()
    .append('foreignObject')
      .attr('id', (d,i)-> "eventHtml-#{i}")
      .attr('class', 'eventHtml')
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+30)
      .attr('width', 245)
      .attr('height', 200)
        .append('xhtml:div')
          .attr('class', 'eventInnerDiv')
  innerDiv.append('input').attr('type', 'number')
      



addEvent = (d,x,y) -> 
  d.x = x-getMainRect().left-125
  d.y  = y-getMainRect().top-125
  eventList.push(d)
  createEvents()

createSidebar = (err, sensors) ->
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
  
  dragstop = (d)->
    d3.select('.dragging').remove()
    source = d3.event.sourceEvent
    element = document.elementFromPoint(source.clientX, source.clientY)
    if element.id == "svgMain" then addEvent(d, source.clientX,source.clientY)
  
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
  
  d3.selectAll('.eventType').each((d, i) -> 
    rect = getRectForSensorIndex(i)
    d.x = rect.left
    d.y = rect.top
  )

  

getRectForSensorIndex = (index) ->
  currentElement = d3.select("#eventType-#{index}").node()
  currentElement.getBoundingClientRect()

getMainRect = ->
  d3.select('#svgMain').node().getBoundingClientRect()

id = (x) -> x  
    
createEvents()
d3.json("http://localhost:8000/data/sensors.json", createSidebar)