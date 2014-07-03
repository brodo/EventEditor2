d3 = require('d3')
util = require('./util.coffee')
module.exports = (connectionList, eventList, update, exit, refresh) ->
  createCombinatorDragStart= (connectionType, nodePostion)-> (d,i)->
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
    while element != null and element.tagName != 'body' and element.id[0..5] != 'event-'
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
  
  dragmove = (data) ->
      data.x = Math.max(0, d3.event.x)
      data.y = Math.max(0, d3.event.y)
      d3.select(@.parentElement).moveToFront()
      refresh()
      update()

  {
    dragAndRect: d3.behavior.drag()
      .on("dragstart", createCombinatorDragStart("and", (d)-> d.andRectMiddle()))
      .on("drag", combinatorDrag("and"))
      .on("dragend",createCombinatorDragEnd("and", (d)-> d.andRectMiddle()))
    ,
    dragFollowedByRect: d3.behavior.drag()
      .on("dragstart", createCombinatorDragStart("followedBy", (d)-> d.followedByRectMiddle()))
      .on("drag", combinatorDrag("followedBy"))
      .on("dragend",createCombinatorDragEnd("followedBy", (d)-> d.followedByRectMiddle()))
    ,
    drag: d3.behavior.drag()
      .origin(util.id)
      .on("drag", dragmove)
    ,
    dragNorthSouth: d3.behavior.drag()
      .origin(util.id)
      .on("drag", (d)-> 
        d.height = Math.max(d.height + d3.event.dy, 100)
        refresh()
        update()
      )
    , 
    dragEastWestRight: d3.behavior.drag()
      .origin(util.id)
      .on("drag", (d)-> 
        d.width = Math.max(d.width + d3.event.dx, 150)
        refresh()
        update()
      )  
    ,
    dragEastWestLeft: d3.behavior.drag()
      .origin(util.id)
      .on("drag", (d)-> 
        d.width = Math.max(d.width - d3.event.dx , 150) 
        d.x += d3.event.dx
        refresh()
        update()
      )
  }