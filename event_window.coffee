d3 = require('d3')
_ = require('lodash')
util = require('./util.coffee')
event_window_enter = require('./event_window_enter.coffee')
d3.selection.prototype.moveToFront = -> @each(-> @parentNode.appendChild(@))
measures =
  eventHeight: 250
  eventWidth: 250
  eventBottomBarHeight: 30
  eventTitleHeight: 30
  eventNameHeight: 25
  andCombinatorButtonWidth: 40
  andCombinatorButtonHeight: 20  
  followedByCombinatorButtonWidth: 70
  followedByCombinatorButtonHeight: 20

closeIconPoints = "438.393,374.595 319.757,255.977 438.378,137.348 
374.595,73.607 255.995,192.225 137.375,73.622 73.607,137.352 192.246,255.983 
73.622,374.625 137.352,438.393 256.002,319.734 374.652,438.378 "

module.exports = (eventList, connectionList, refreshMain) ->
  removeEvent = (d,i)-> 
    while true
      indx = _.findIndex(connectionList, (c)-> c.source == i or c.target == i)
      if indx == -1 then break
      connectionList.splice(indx,1)
    eventList.splice(i,1)
    exit()
    refreshMain()

  enter = event_window_enter(
    connectionList,
    eventList,
    measures,
    closeIconPoints,
    removeEvent,
    update,
    exit,
    refreshMain)

  update = ->
    console.log("%c [EventWindow] update", util.greenItalic)
    events = d3.select('.events').selectAll('.event').data(eventList, (d)-> d.id)
    events
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)
      .attr('width', (d)-> d.width)
      .attr('height', (d)-> d.height)

    d3.selectAll('.eventNameContainer')
      .attr('x', (d) -> d.nameContainer().x)
      .attr('y', (d) -> d.nameContainer().y)

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

    # Update pattern name in event select element
    d3.selectAll('.eventSelector').selectAll('.otherEventNames')
      .data((d)-> eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id))
      .text((d)-> d.patternName)
  
  exit = ->
    console.log("%c [EventWindow] exit", util.greenItalic)
    events = d3.selectAll('.event').data(eventList, (d)-> d.id)
    events.exit().remove()
    events.selectAll('.parameter').data((d)-> d.parameters)
      .selectAll('.condition').data(((d)-> d.conditions), ((d)-> d.id))
      .exit()
      .remove()

    d3.selectAll('.eventSelector').selectAll('.otherEventNames')
      .data((d)->
        eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id)
      )
      .exit()
      .remove()
    d3.selectAll('.eventPropertySelector').selectAll('.otherEventProperty').data(util.id).exit().remove()

  update: update
  enter: enter
  exit: exit
  measures: measures