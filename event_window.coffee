d3 = require('d3')
util = require('./util.js')
_ = require('lodash')
d3.selection.prototype.moveToFront = -> @each(-> @parentNode.appendChild(@))
measures = 
  eventHeight: 250
  eventWidth: 250
  eventBottomBarHeight: 30
  eventTitleHeight: 30
  andCombinatorButtonWidth: 40
  andCombinatorButtonHeight: 20  
  followedByCombinatorButtonWidth: 70
  followedByCombinatorButtonHeight: 20

closeIconPoints = "438.393,374.595 319.757,255.977 438.378,137.348 
374.595,73.607 255.995,192.225 137.375,73.622 73.607,137.352 192.246,255.983 
73.622,374.625 137.352,438.393 256.002,319.734 374.652,438.378 "

module.exports = (eventList, connectionList, refresh) ->
  
  createCombinatorDragStart = (connectionType, nodePostion)-> (d,i)->
    connection = connectionList.filter((e)-> (e.source == i or e.target == i) and e.type == connectionType)
    if connection.length == 0
      nodes = [1,2,3].map(-> nodePostion(d))
      connection =
        nodes: nodes
        target: null
        source: i
        middleHasBeenDragged: false
        type: connectionType
        id: Date.now()
      connectionList.push(connection)
    else
      connection[0].target = null
      connection[0].source = i
    enter()
    refresh()

  combinatorDrag = (connectionType) -> (d,i)->
    connection = connectionList.filter((c)-> c.source == i and c.type == connectionType)[0]
    [start, middle, end] = connection.nodes
    newMiddle = d3.interpolateObject(start, end)(0.5)
    middle.x = newMiddle.x
    middle.y = newMiddle.y
    end.x = d3.event.x-2
    end.y = d3.event.y-2
    refresh()
    update()

  createCombinatorDragEnd = (connectionType, nodePostion)-> (d,i)->
    connection = connectionList.filter((c)-> c.source == i and c.type == connectionType)[0]
    [start, middle, end] = connection.nodes
    connection.target = null
    element = d3.event.sourceEvent.toElement
    while element != null and element.tagName != 'body' and element.id[0..4] != 'event'
      element = element.parentElement
    if element != null and element.tagName != 'body' and element.id != "event-#{i}"
      target = parseInt(element.id[6..], 10)
      index = _.findIndex(connectionList, (c)->
        (c.source == i and c.target == target) or (c.source == target and c.target == i) 
      )
      if index != -1
        connectionList.splice(index,1)
      connection.target = target
      position = nodePostion(eventList[connection.target])
      end.x = position.x
      end.y = position.y
    else 
      connectionList.splice(connectionList.indexOf(connection), 1)
    exit()
    refresh()
    update()

  dragAndRect = d3.behavior.drag()
    .on("dragstart", createCombinatorDragStart("and", (d)-> d.andRectMiddle()))
    .on("drag", combinatorDrag("and"))
    .on("dragend",createCombinatorDragEnd("and", (d)-> d.andRectMiddle()))

  dragFollowedByRect = d3.behavior.drag()
    .on("dragstart", createCombinatorDragStart("followedBy", (d)-> d.followedByRectMiddle()))
    .on("drag", combinatorDrag("followedBy"))
    .on("dragend",createCombinatorDragEnd("followedBy", (d)-> d.followedByRectMiddle()))


  dragmove = (data) ->
    data.x = Math.max(0, d3.event.x)
    data.y = Math.max(0, d3.event.y)
    d3.select(@.parentElement).moveToFront()
    refresh()
    update()
    
  drag = d3.behavior.drag()
    .origin(util.id)
    .on("drag", dragmove)

  dragNorthSouth = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.height = Math.max(d.height + d3.event.dy, 100)
      refresh()
      update()
    )  
  dragEastWestRight = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.width = Math.max(d.width + d3.event.dx, 150)
      refresh()
      update()
    )  

  dragEastWestLeft = d3.behavior.drag()
    .origin(util.id)
    .on("drag", (d)-> 
      d.width = Math.max(d.width - d3.event.dx , 150) 
      d.x += d3.event.dx
      refresh()
      update()
    )

  removeEvent = (d,i)-> 
    while true
      indx = _.findIndex(connectionList, (c)-> c.source == i or c.target == i)
      if indx == -1 then break
      connectionList.splice(indx,1)
    eventList.splice(i,1)
    exit()
    refresh()

  enter = ->
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
      .on('click', (d)-> d3.select(@.parentElement).moveToFront())
    
    eventGroupEnter.append('rect')
      .attr('class', 'andRect')
      .attr('width', measures.andCombinatorButtonWidth)
      .attr('height', measures.andCombinatorButtonHeight)
      .attr('rx', 5)
      .attr('dx', 5)
      .attr('y', (d)-> d.andRect().y)
      .attr('x', (d) -> d.andRect().x)
      .call(dragAndRect) 

    eventGroupEnter.append('text')
      .attr('class', 'andLabel')
      .attr('width', measures.andCombinatorButtonWidth)
      .attr('height', measures.andCombinatorButtonHeight)
      .attr('y', (d)-> d.andRectMiddle().y )
      .attr('x', (d) -> d.andRectMiddle().x)
      .text('And')
      .call(dragAndRect)    

    eventGroupEnter.append('rect')
      .attr('class', 'followedByRect')
      .attr('width', measures.followedByCombinatorButtonWidth)
      .attr('height', measures.followedByCombinatorButtonHeight)
      .attr('rx', 5)
      .attr('dx', 5)
      .attr('y', (d)-> d.followedByRect().y)
      .attr('x', (d) -> d.followedByRect().x)
      .call(dragFollowedByRect) 

    eventGroupEnter.append('text')
      .attr('class', 'followedByLabel')
      .attr('width', measures.followedByCombinatorButtonWidth)
      .attr('height', measures.followedByCombinatorButtonHeight)
      .attr('y', (d)-> d.followedByRectMiddle().y)
      .attr('x', (d) -> d.followedByRectMiddle().x)
      .text('Followed By')
      .call(dragFollowedByRect)




    innerDiv = eventGroupEnter.append('foreignObject')
      .attr('overflow', 'auto')
      .attr('id', (d,i)-> "eventHtml-#{i}")
      .attr('class', 'eventHtml')
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+measures.eventTitleHeight)
      .attr('width', (d)-> d.width-10)
      .attr('height', (d)-> d.height-measures.eventBottomBarHeight-measures.eventTitleHeight)
        .append('xhtml:div')
          .attr('class', 'eventInnerDiv')
          .style('width', (d)-> "#{d.width-10}px")
          .style('height', (d)-> "#{d.height-measures.eventBottomBarHeight-measures.eventTitleHeight}px")

    parameters = innerDiv.append('div').attr('class', 'parameters')

    parameterEnter = parameters.selectAll('.parameter').data((d)-> d.parameters ).enter()
      .append('div').attr('class', 'parameter')
    
    parameterEnter.append('label')
      .text((d) -> if d.unit != null and d.unit != '' then "#{d.displayName} (#{d.unit}): " else "#{d.displayName}: ")
      .attr('for', (d,i) -> "param-#{i}")

    parameterEnter.append('span')
      .attr('class', "paramMiddle")

    parameterEnter.append('button')
      .attr('class', "addConditionButton")
      .text('+')
      .on('click', (d,i)->
        length = d.conditions.length 
        d.conditions.push(
          comparators: d.comparators
          type: d.type
          value: null
          combinator: (if length == 0 then null else 'and')
          width: d.width
          comparator: d.comparators[0]
          id: Date.now()
          isLink: false
          index: length
          parentIndex: i
        )
        enter()
      )


      
    parameterEnter.append('button')
      .attr('class', "addLinkConditionButton")
      .attr('disabled', true)
      .text('o')
      .on('click', (d, i)->
        length = d.conditions.length
        console.log("OtherEvent:")
        console.dir(eventList.filter((e)-> e.id != d.parentId)[0]) 
        d.conditions.push(
          comparators: d.comparators
          type: d.type
          value: null
          combinator: (if length == 0 then null else 'and')
          width: d.width
          comparator: d.comparators[0]
          id: Date.now()
          isLink: true
          index: length
          parentIndex: i
          otherEvent: eventList.filter((e)-> e.id != d.parentId)[0].id
        )
        enter()
      )
    d3.selectAll('.addLinkConditionButton').filter(()-> eventList.length > 1)
      .attr('disabled', null)
    
    conditionsEnter = d3.selectAll('.paramMiddle').selectAll('.condition')
      .data((d)-> d.conditions).enter()
        .append('div').attr('class', 'condition')

    conditionsEnter.filter((d)-> d.combinator != null)
      .append('select')
        .attr('class',  'combinator')
        .on('change', (d) -> d.combinator = @value)
        .selectAll('.combinatorOption')
          .data((d)-> ['And', 'Or'])
          .enter()
          .append('option')
            .attr('class', 'combinatorOption')
            .attr('value', (d)->d)
            .text((d)->d)

    linkSelectors = conditionsEnter.filter((d)-> d.isLink)
      .append('span')
        .attr('class', 'linkSelectors')
    
    linkSelectors.append('select')
      .attr('class', 'eventSelector')
      .on('change', (d)->d.otherEvent = @value)
      .selectAll('.otherEventNames')
      .data((d)-> 
        eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id)
      ).enter()
      .append('option')
        .attr('class', 'otherEventNames')
        .attr('value', (d)-> d.id)
        .text((d)-> d.patternName)


    linkSelectors.append('select')
      .attr('class', 'eventPropertySelector')
      .selectAll('.otherEventProperty')
      .data((d)-> 
        if d.otherEvent == null then return []
        console.dir(d)
        otherEvent = eventList.filter((e)-> e.id == d.otherEvent)[0]
        otherEvent.parameters
      ).enter()
        .append('option')
          .attr('class', 'otherEventProperty')
          .attr('value', (d)-> d.id)
          .text((d)-> d.displayName)




    conditionsEnter
      .append('select')
        .attr('class', 'comparatorSelect')
        .on('change', (d) -> d.comparator = @value)
        .selectAll('.comparatorOption')
          .data((d)-> d.comparators)
          .enter()
          .append('option')
            .attr('class', 'comparatorOption')
            .attr('value', (d)-> d)
            .text((d) -> d)

    conditionsEnter.append('input')
      .attr('type', (d)-> d.type)
      .attr('value', (d)-> d.value)
      .attr('class', 'valueInput')
      .style('width', (d) -> "#{d.width}px")
      .on('input', (d)-> d.value = @value)

    conditionsEnter.append('button')
      .attr('class', 'deleteCondition')
      .text('-')
      .on('click', (d,i) ->
        d3.select(@parentNode.parentNode).datum().conditions.splice(i,1)
        exit()
      )

    eventName = innerDiv.append('xhtml:div')
      .attr('class', 'eventName')
    
    eventName.append('label').text('Event Name:')
    eventName.append('input').on('input', (d)-> 
      d.patternName = @value
      update()
    ).attr('class', 'patterNameInput')
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



  update = ->
    events = d3.select('.events').selectAll('.event').data(eventList, (d)-> d.id)
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
      .attr('height', (d)-> d.height-60)

    d3.selectAll('.eventInnerDiv')
      .style('width', (d)-> "#{d.width-10}px")
      .style('height', (d)-> "#{d.height-50}px}")

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

    d3.selectAll('.andLabel')
      .attr('y', (d)-> d.andRectMiddle().y )
      .attr('x', (d) -> d.andRectMiddle().x )

    d3.selectAll('.followedByRect')
      .attr('y', (d)-> d.followedByRect().y)
      .attr('x', (d) -> d.followedByRect().x)
      
    d3.selectAll('.followedByLabel')
      .attr('y', (d)-> d.followedByRectMiddle().y )
      .attr('x', (d) -> d.followedByRectMiddle().x )

    d3.selectAll('.eventSelector').selectAll('.otherEventNames')
      .data((d)->
        eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id)
      )
      .text((d)-> d.patternName)

    d3.selectAll('.eventSelector').selectAll('.otherEventNames')
      .data((d)->
        eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id)
      ).enter()
        .append('option')
        .attr('class', 'otherEventNames')
        .attr('value', (d)-> d.id)
        .text((d)-> d.patternName)


  exit = ->
    events = d3.selectAll('.event').data(eventList, (d)-> d.id)
    events.exit().remove()
    events.selectAll('.parameter').data((d)-> d.parameters)
      .selectAll('.condition').data(((d)-> d.conditions), ((d)-> d.id))
      .exit()
      .remove()

  update: update
  enter: enter
  exit: exit
  measures: measures