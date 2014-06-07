d3 = require('d3')
util = require('./util.js')
d3.selection.prototype.moveToFront = -> @each(-> @parentNode.appendChild(@))
measures = 
  eventHeight: 250
  eventWidth: 250
  eventBottomBarHeight: 30
  eventTitleHeight: 30
  combinatorButtonWidth: 40
  combinatorButtonHeight: 20

closeIconPoints = "438.393,374.595 319.757,255.977 438.378,137.348 
374.595,73.607 255.995,192.225 137.375,73.622 73.607,137.352 192.246,255.983 
73.622,374.625 137.352,438.393 256.002,319.734 374.652,438.378 "

module.exports = (eventList, connectionList) ->
  
  dragAndRect = d3.behavior.drag()
    .on("dragstart", (d,i)->
      nodes = [1,2,3].map(-> d.andRectMiddle())
      connection =
        nodes: nodes
        target: null
        source: i 
      connectionList.push(connection)
      enter()
    )
    .on("drag", (d,i)->
      connection = connectionList.filter((c)-> c.source == i)[0]
      [start, middle, end] = connection.nodes
      newMiddle = d3.interpolateObject(start, end)(0.5)
      middle.x = newMiddle.x
      middle.y = newMiddle.y
      end.x = d3.event.x-2
      end.y = d3.event.y-2
      update()
    ).on("dragend",(d,i)->
      connection = connectionList.filter((c)-> c.source == i)[0]
      [start, middle, end] = connection.nodes
      element = d3.event.sourceEvent.toElement
      while element != null and element.tagName != 'body' and element.id[0..4] != 'event'
        element = element.parentElement
      if element != null and element.tagName != 'body' and element.id != "event-#{i}"
        connection.target = parseInt(element.id[6..], 10)
        end.x = eventList[connection.target].andRectMiddle().x
        end.y = eventList[connection.target].andRectMiddle().y
      else 
        connectionList.splice(connectionList.indexOf(connection), 1)
      update()
      exit()
    )

  dragmove = (data) ->
    data.x = Math.max(0,d3.event.x)
    data.y = Math.max(0,d3.event.y)
    d3.select(@.parentElement).moveToFront()
    update() 
    
  drag = d3.behavior.drag()
    .origin(util.id)
    .on("drag", dragmove)

  dragNorthSouth = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.height += d3.event.dy
      update()
    )  
  dragEastWestRight = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.width += d3.event.dx
      update()
    )  

  dragEastWestLeft = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.width -= d3.event.dx
      d.x += d3.event.dx
      update()
    )
  removeEvent = (d,i)-> 
    eventList.splice(i,1)
    exit()

  enter = ->
    events = d3.select('.events').selectAll('.event').data(eventList)
    eventGroupEnter = events.enter().append('g')
      .attr('class', 'event')
      .attr('id', (d,i)-> "event-#{i}")

    eventGroupEnter.append('rect')
      .attr('class', 'eventRect')
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)
      .attr('x', (d)-> d.x)
      .attr('y', (d)-> d.y)
    
    eventGroupEnter.append('rect')
      .attr('class', 'eventTitleRect')
      .attr('width', (d)-> d.width)
      .attr('height', measures.eventTitleHeight)
      .attr('x', (d)-> d.x)
      .attr('y', (d)-> d.y)
      .call(drag)
      .on('click', (d)-> d3.select(@.parentElement).moveToFront())

    eventGroupEnter.append('polygon')
      .attr('class', 'closeButton')
      .attr('points', closeIconPoints)
      .attr('transform', (d)-> "translate(#{d.x+d.width-30},#{d.y+3}) scale(0.05)")
      .on('click', removeEvent)

    eventGroupEnter.append('text')
      .attr('class', 'eventTitle')
      .attr('y', (d)-> d.y + 25)
      .attr('x', (d) -> d.x + d.width/2)
      .attr('width', (d)-> d.width-10)
      .text((d)-> d.displayName)
      .call(drag)
    
    eventGroupEnter.append('rect')
      .attr('class', 'andRect')
      .attr('width', measures.combinatorButtonWidth)
      .attr('height', measures.combinatorButtonHeight)
      .attr('rx', 5)
      .attr('dx', 5)
      .attr('y', (d)-> d.andRect().y)
      .attr('x', (d) -> d.andRect().x)
      .call(dragAndRect) 

    innerDiv = eventGroupEnter.append('foreignObject')
      .attr('id', (d,i)-> "eventHtml-#{i}")
      .attr('class', 'eventHtml')
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+measures.eventTitleHeight)
      .attr('width', (d)-> d.width-10)
      .attr('height', (d)-> d.height-measures.eventBottomBarHeight-measures.eventTitleHeight)
        .append('xhtml:div')
          .attr('class', 'eventInnerDiv')
    
    innerDiv.selectAll('.parameter').data((d)-> d.parameters ).enter()
      .append('div')
        .attr('class', 'parameter')
        .append('label')
          .text((d) -> d.displayName)
          .attr('for', (d,i) -> "param-#{i}")

    eventGroupEnter.append('rect')
      .attr('class', 'leftResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', 3)
      .attr('height', (d) -> d.height)
      .call(dragEastWestLeft)

    eventGroupEnter.append('rect')
      .attr('class', 'rightResizeBar')
      .attr('x', (d) -> d.x+d.width)
      .attr('y', (d) -> d.y)
      .attr('width', 3)
      .attr('height', (d) -> d.height)
      .call(dragEastWestRight)

    eventGroupEnter.append('rect')
      .attr('class', 'bottomResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y+d.height)
      .attr('width', (d)-> d.width)
      .attr('height', 3)
      .call(dragNorthSouth)

  update = ->
    events = d3.select('.events').selectAll('.event').data(eventList)
    events
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)

    d3.selectAll('.eventRect')
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)

    d3.selectAll('.eventTitleRect')
      .attr('width', (d)-> d.width)
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)  

    d3.selectAll('.closeButton')
      .attr('transform', (d)-> "translate(#{d.x+d.width-30},#{d.y+3}) scale(0.05)")

    d3.selectAll('.eventTitle')
      .attr('y', (d)-> d.y + 25)
      .attr('x', (d) -> d.x + d.width/2)
      .attr('width', (d)-> d.width-10)

    d3.selectAll('.eventHtml')
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+30)
      .attr('width', (d)-> d.width-10)
      .attr('height', (d)-> d.height-50)

    d3.selectAll('.leftResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', 1)
      .attr('height', (d) -> d.height)

    d3.selectAll('.rightResizeBar')
      .attr('x', (d) -> d.x+d.width)
      .attr('y', (d) -> d.y)
      .attr('width', 1)
      .attr('height', (d) -> d.height) 

    d3.selectAll('.bottomResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y+d.height)
      .attr('width', (d)-> d.width)

    d3.selectAll('.andRect')
      .attr('y', (d)-> d.andRect().y)
      .attr('x', (d) -> d.andRect().x)

  exit = ->
    events = d3.select('.events').selectAll('.event').data(eventList)
    events.exit().remove()

  update: update
  enter: enter
  exit: exit
  measures: measures


