d3 = require('d3')
_ = require('lodash')
util = require('./util.coffee')
eplGenerator = require('./eplGenerator.coffee')
Title = require('./event_window_title.coffee')
Body = require('./event_window_body.coffee')
Connectors = require('./event_window_connectors.coffee')
eplElement = document.querySelector('#eplOutput')

d3.selection.prototype.moveToFront = -> @each(-> @parentNode.appendChild(@))
measures =
  eventHeight: 250
  eventWidth: 250
  eventBottomBarHeight: 30
  eventNameHeight: 25
  andCombinatorButtonWidth: 40
  andCombinatorButtonHeight: 20  
  followedByCombinatorButtonWidth: 70
  followedByCombinatorButtonHeight: 20
  eventTitleHeight: 30
  whereWindowHeight: 40
  whereWindowWidth: 180
  whereWindowTopMargin: 20

module.exports = (eventList, connectionList, refreshMain) ->  
  dragNorthSouth = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.height = Math.max(d.height + d3.event.dy, 100)
      refreshMain()
      update()
    )
   
  dragEastWestRight = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.width = Math.max(d.width + d3.event.dx, 150)
      refreshMain()
      update()
    )  
  
  dragEastWestLeft = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.width = Math.max(d.width - d3.event.dx , 150) 
      d.x += d3.event.dx
      refreshMain()
      update()
    )

  removeEvent = (d,i)-> 
    while true
      indx = _.findIndex(connectionList, (c)-> c.source == i or c.target == i)
      if indx == -1 then break
      connectionList.splice(indx,1)
    eventList.splice(i,1)
    exit()
    refreshMain()
  d3Functions = {}

  title = Title(refreshMain, d3Functions, removeEvent, measures.eventTitleHeight)
  body = Body(refreshMain, d3Functions, measures)
  connectors = Connectors(refreshMain, d3Functions, measures)

  enter = ->
    if not (eplElement == document.activeElement) then eplElement.value = eplGenerator(eventList, connectionList)
    util.debug and console.log("%c[EventWindow] %cEnter", util.greenBold, util.bold)

    events = d3.select('.events').selectAll('.event').data(eventList, (d)-> d.id)
    eventGroupEnter = events.enter().append('g')
      .attr('class', 'event')
      .attr('id', (d,i)-> "event-#{i}")

    eventGroupEnter.append('rect')
      .attr('class', 'eventRect')
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)
      .attr('x', (d)-> d.x)
      .attr('y', (d)-> d.y)
    
    title.enter(eventGroupEnter)

    connectors.enter(eventGroupEnter)

    body.enter(eventGroupEnter)

    eventName = eventGroupEnter.append('foreignObject')
      .attr('class', 'eventNameContainer')
      .attr('x', (d)-> d.nameContainer().y)
      .attr('y', (d)-> d.nameContainer().x)
      .attr('width', (d)-> d.width-10)
      .attr('height', measures.eventNameHeight)
        .append('xhtml:div')
        .attr('class', 'eventName')
    
    eventName.append('label').text('Event Name:')
    eventName.append('input').on('input', (d)-> 
        d.patternName = @value
        update()
      )
      .attr('class', 'patterNameInput')
      .attr('value',(d)-> d.patternName)

   
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

    # d3.selectAll('.eventPropertySelector').selectAll('.otherEventProperty')
    #   .attr('value', (d)-> d.name)
    #   .text((d)-> d.displayName)

  update = ->
    if not (eplElement == document.activeElement) then eplElement.value = eplGenerator(eventList, connectionList)
    util.debug and console.log("%c[EventWindow] %cUpdate", util.greenBold, util.bold)
    events = d3.select('.events').selectAll('.event').data(eventList, (d)-> d.id)
    events
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)

    d3.selectAll('.eventNameContainer')
      .attr('x', (d) -> d.nameContainer().x)
      .attr('y', (d) -> d.nameContainer().y)
      .attr('width', (d)-> d.width - 25)

    d3.selectAll('.eventRect')
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)

    title.update()

    d3.selectAll('.eventHtml')
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+30)
      .attr('width', (d)-> d.width-10)
      .attr('height', (d)-> d.height-60)

    d3.selectAll('.eventInnerDiv')
      .style('width', (d)-> "#{d.width-10}px")
      .style('height', (d)->"#{d.height-70}px")

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

    connectors.update()
    body.update()
  
  exit = ->
    if not (eplElement == document.activeElement) then eplElement.value = eplGenerator(eventList, connectionList)
    util.debug and console.log("%c[EventWindow] %cExit", util.greenBold, util.bold)
    d3.selectAll('.event').data(eventList, (d)-> d.id).exit().remove()
    body.exit()
    

  d3Functions.update = update
  d3Functions.enter = enter
  d3Functions.exit = exit

  update: update
  enter: enter
  exit: exit
  measures: measures