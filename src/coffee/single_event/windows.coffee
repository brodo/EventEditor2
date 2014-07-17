util = require('./util.coffee')
eplGenerator = require('./eplGenerator.coffee')
Title = require('./window_title.coffee')
EventBody = require('./event_window_body.coffee')
PatternBody = require('./pattern_window_body.coffee')
Connectors = require('./window_connectors.coffee')
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

module.exports = (eventList, patternList, connectionList, refreshMain) ->  
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

  removePattern = (d,i)-> 
    while true
      indx = _.findIndex(patternList, (c)-> c.source == i or c.target == i)
      if indx == -1 then break
      patternList.splice(indx,1)
    patternList.splice(i,1)
    exit()
    refreshMain()
  d3Functions = {}

  windowEnter = (className, list, body, connectors, title, customize)->
    if not (eplElement == document.activeElement) then eplElement.value = eplGenerator(eventList, connectionList)
    util.debug and console.log("%c[EventWindow] %cEnter", util.greenBold, util.bold)

    windows = d3.select(".#{className}s").selectAll(".#{className}").data(list, (d)-> d.id)
    windowGroupEnter = windows.enter().append('g')
      .attr('class', className)
      .attr('id', (d,i)-> "window-#{d.id}")

    windowGroupEnter.append('rect')
      .attr('class', "#{className}Rect")
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)
      .attr('x', (d)-> d.x)
      .attr('y', (d)-> d.y)
    
    title.enter(windowGroupEnter)

    connectors.enter(windowGroupEnter)

    body.enter(windowGroupEnter)

    if customize then customize(windowGroupEnter)

    windowGroupEnter.append('rect')
      .attr('class', 'leftResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', 3)
      .attr('height', (d) -> d.height)
      .call(dragEastWestLeft)

    windowGroupEnter.append('rect')
      .attr('class', 'rightResizeBar')
      .attr('x', (d) -> d.x+d.width)
      .attr('y', (d) -> d.y)
      .attr('width', 3)
      .attr('height', (d) -> d.height)
      .call(dragEastWestRight)

    windowGroupEnter.append('rect')
      .attr('class', 'bottomResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y+d.height)
      .attr('width', (d)-> d.width)
      .attr('height', 3)
      .call(dragNorthSouth)

  windowUpdate = (className, list, body, connectors, title, customize) ->
    if not (eplElement == document.activeElement) 
      eplElement.value = eplGenerator(eventList, connectionList)
    util.debug and console.log("%c[EventWindow] %cUpdate", util.greenBold, util.bold)
    windows = d3.select(".#{className}s")
      .selectAll(".#{className}")
      .data(list, (d)-> d.id)

    windows
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)


    d3.selectAll(".#{className}Rect")
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)

    title.update()

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

    d3.selectAll(".#{className}Html")
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+30)
      .attr('width', (d)-> d.width-10)
      .attr('height', (d)-> d.height-60)
  
    d3.selectAll(".#{className}InnerDiv")
      .style('width', (d)-> "#{d.width-10}px")
      .style('height', (d)->"#{d.height-70}px")


    connectors.update()
    body.update()
    if customize then customize()
  
  windowExit = (className, body, list) ->
    if not (eplElement == document.activeElement) then eplElement.value = eplGenerator(eventList, connectionList)
    util.debug and console.log("%c[EventWindow] %cExit", util.greenBold, util.bold)
    d3.selectAll(".#{className}").data(list, (d)-> d.id).exit().remove()
    body.exit()
  
  patternBody = PatternBody(refreshMain, d3Functions, measures)
  patternTitle = Title("patern",refreshMain, d3Functions, removePattern, measures.eventTitleHeight)
  eventBody = EventBody(refreshMain, d3Functions, measures)
  connectors = Connectors(refreshMain, d3Functions, measures)
  title = Title("event",refreshMain, d3Functions, removeEvent, measures.eventTitleHeight)
  enter = ->
    windowEnter('event', eventList, eventBody, connectors, title, (windowGroupEnter) ->
      eventName = windowGroupEnter.append('foreignObject')
        .attr('class', 'eventNameContainer')
        .attr('x', (d)-> d.nameContainer().x)
        .attr('y', (d)-> d.nameContainer().y)
        .attr('width', (d)-> d.width-10)
        .attr('height', measures.eventNameHeight)
          .append('xhtml:div')
          .attr('class', 'eventName')
    
      eventName.append('label').text('Event Name:')
      eventName.append('input').on('input', (d)-> 
          d.patternName = @value
          update()
        )
        .attr('class', 'patternNameInput')
        .attr('value',(d)-> d.patternName)
    )

    windowEnter('pattern', patternList, patternBody, connectors, title)

  update = ->
    windowUpdate('event', eventList, eventBody, connectors, title, ->
      d3.selectAll('.eventNameContainer')
        .attr('x', (d) -> d.nameContainer().x)
        .attr('y', (d) -> d.nameContainer().y)
        .attr('width', (d)-> d.width - 25)
    )

    windowUpdate('pattern', patternList, patternBody, connectors, title)

  exit = ->
    windowExit("event", eventBody, eventList)


  d3Functions.update = update
  d3Functions.enter = enter
  d3Functions.exit = exit

  update: update
  enter: enter
  exit: exit
  measures: measures