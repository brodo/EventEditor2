d3 = require('d3')
util = require('./util.coffee')
dragLib = require('./event_window_drag.coffee')
module.exports = (connectionList, eventList, measures, closeIconPoints, removeEvent, update, exit, refreshMain) ->
  drag = dragLib(connectionList, eventList, update, exit, refreshMain)
  () ->
    console.log("%c [EventWindow] %cEnter what??", util.greenItalic, util.bold)
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
      .on('click', (d)-> d3.select(@parentElement).moveToFront())
      .call(drag.drag)

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
      .on('click', (d)-> d3.select(@parentElement).moveToFront())
      .call(drag.drag)
    
    eventGroupEnter.append('rect')
      .attr('class', 'andRect')
      .attr('width', measures.andCombinatorButtonWidth)
      .attr('height', measures.andCombinatorButtonHeight)
      .attr('rx', 5)
      .attr('dx', 5)
      .attr('y', (d)-> d.andRect().y)
      .attr('x', (d) -> d.andRect().x)
      .call(drag.dragAndRect) 

    eventGroupEnter.append('text')
      .attr('class', 'andLabel')
      .attr('width', measures.andCombinatorButtonWidth)
      .attr('height', measures.andCombinatorButtonHeight)
      .attr('y', (d)-> d.andRectMiddle().y )
      .attr('x', (d) -> d.andRectMiddle().x)
      .text('And')
      .call(drag.dragAndRect)    

    eventGroupEnter.append('rect')
      .attr('class', 'followedByRect')
      .attr('width', measures.followedByCombinatorButtonWidth)
      .attr('height', measures.followedByCombinatorButtonHeight)
      .attr('rx', 5)
      .attr('dx', 5)
      .attr('y', (d)-> d.followedByRect().y)
      .attr('x', (d) -> d.followedByRect().x)
      .call(drag.dragFollowedByRect) 

    eventGroupEnter.append('text')
      .attr('class', 'followedByLabel')
      .attr('width', measures.followedByCombinatorButtonWidth)
      .attr('height', measures.followedByCombinatorButtonHeight)
      .attr('y', (d)-> d.followedByRectMiddle().y)
      .attr('x', (d) -> d.followedByRectMiddle().x)
      .text('Followed By')
      .call(drag.dragFollowedByRect)

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
      .on('change', (d)->
        update()
        d.otherEvent = @value
      )
      .selectAll('.otherEventNames')
      .data((d)-> 
        eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id)
      ).enter()
      .append('option')
        .attr('class', 'otherEventNames')
        .attr('value', (d)-> d.id)
        .text((d)-> d.patternName)


    eventPropertyStelectors = linkSelectors.append('select')
      .attr('class', 'eventPropertySelector')
      .selectAll('.otherEventProperty')
      .data((d)-> 
        if d.otherEvent == null then return []
        otherEvent = eventList.filter((e)-> e.id == d.otherEvent)[0]
        otherEvent.parameters
      )

    eventPropertyStelectors.enter()
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

    eventGroupEnter.append('rect')
      .attr('class', 'leftResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', 3)
      .attr('height', (d) -> d.height)
      .call(drag.dragEastWestLeft)

    eventGroupEnter.append('rect')
      .attr('class', 'rightResizeBar')
      .attr('x', (d) -> d.x+d.width)
      .attr('y', (d) -> d.y)
      .attr('width', 3)
      .attr('height', (d) -> d.height)
      .call(drag.dragEastWestRight)

    eventGroupEnter.append('rect')
      .attr('class', 'bottomResizeBar')
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y+d.height)
      .attr('width', (d)-> d.width)
      .attr('height', 3)
      .call(drag.dragNorthSouth)

    # d3.selectAll('.eventPropertySelector').selectAll('.otherEventProperty')
    #   .attr('value', (d)-> d.name)
    #   .text((d)-> d.displayName)