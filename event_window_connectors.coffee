d3 = require('d3')
module.exports = (refreshMain, d3Functions, measures) ->

  connectorLine = d3.svg.line().x((d)-> d.x).y((d)->d.y).interpolate('linear')

  dragConnector =  d3.behavior.drag()
    .origin((d)-> d.nodes[1])
    .on("drag", (d)->
      d.nodes[1].x = Math.max(0, d3.event.x)
      d.nodes[1].y = Math.max(0, d3.event.y)
      d.middleHasBeenDragged = true
      d3.select(@.parentElement).moveToFront()
      update()
    )

  combinatorDrag = (connectionType) -> (d,i)->
    connection = connectionList.filter((c)-> c.source == i)[0]
    connection.type = connectionType
    [start, middle, end] = connection.nodes
    newMiddle = d3.interpolateObject(start, end)(0.5)
    middle.x = newMiddle.x
    middle.y = newMiddle.y
    end.x = d3.event.x-2
    end.y = d3.event.y-2
    refreshMain()
    d3Functions.update()

  createCombinatorDragStart= (connectionType, nodePostion)-> (d,i)->
    connections = connectionList.filter((e)-> e.source == i)
    if connections.length == 0
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
      connections[0].target = null
    d3Functions.enter()
    refreshMain()

  isLoop = ->
    connectionList.length >= eventList.length


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
      if isLoop()
        connectionList.pop()
      connection.target = target
      position = nodePostion(eventList[connection.target])
      end.x = position.x
      end.y = position.y
    else 
      connectionList.splice(connectionList.indexOf(connection), 1)
    d3Functions.exit()
    refreshMain()
    d3Functions.update()

  dragAndRect = d3.behavior.drag()
    .on("dragstart", createCombinatorDragStart("and", (d)-> d.andRectMiddle()))
    .on("drag", combinatorDrag("and"))
    .on("dragend",createCombinatorDragEnd("and", (d)-> d.andRectMiddle()))
  
  dragFollowedByRect = d3.behavior.drag()
    .on("dragstart", createCombinatorDragStart("followedBy", (d)-> d.followedByRectMiddle()))
    .on("drag", combinatorDrag("followedBy"))
    .on("dragend",createCombinatorDragEnd("followedBy", (d)-> d.followedByRectMiddle()))
  
  enter = (eventGroupEnter) ->
    conn = d3.select('#svgMain').selectAll('.connector').data(connectionList, (d)-> d.id)
      .enter().append('g').attr('class', 'connector')
    
    conn.append('path')
      .attr('class', 'connectorPath')
      .attr('stroke', 'black')
      .attr('stroke-width', 3)
      .attr('fill', 'none')
      .attr('d', (d)-> connectorLine(d.nodes))
    
    conn.append('circle')
      .attr('class', 'connectorCircle')
      .attr('cx', (d)-> d.nodes[1].x)
      .attr('cy', (d)-> d.nodes[1].y)
      .attr('r', 20)
      .call(dragConnector)

    conn.append('text')
      .attr('class', 'connectorText')
      .text((d)-> if d.type == "and" then '⋀' else '→')
      .attr('x', (d)-> d.nodes[1].x)
      .attr('y', (d)-> d.nodes[1].y)
      .attr('width', 15)
      .attr('height', 15)
      .call(dragConnector)

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
  
  update = ->
    connectionList.forEach((e)-> 
      [start, middle, end] = e.nodes
      source = eventList[e.source]
      if e.type == "and"
        start.x = source.andRectMiddle().x
        start.y = source.andRectMiddle().y
      else
        start.x = source.followedByRectMiddle().x
        start.y = source.followedByRectMiddle().y
      if not e.middleHasBeenDragged
        newMiddle = d3.interpolateObject(start, end)(0.5)
        middle.x = newMiddle.x
        middle.y = newMiddle.y
      if (typeof e.target) != 'undefined' and e.target != null
        target = eventList[e.target]
        if e.type == "and"
          end.x = target.andRectMiddle().x
          end.y = target.andRectMiddle().y
        else
          end.x = target.followedByRectMiddle().x
          end.y = target.followedByRectMiddle().y
    )

    d3.selectAll('.connectorPath').data(connectionList, (d)-> d.id)
      .attr('d', (d) -> connectorLine(d.nodes))
    
    d3.selectAll('.connectorCircle').data(connectionList, (d)-> d.id)
      .attr('cx', (d)-> d.nodes[1].x)
      .attr('cy', (d)-> d.nodes[1].y)
    
    d3.selectAll('.connectorText').data(connectionList, (d)-> d.id)
      .attr('x', (d)-> d.nodes[1].x)
      .attr('y', (d)-> d.nodes[1].y)
      .text((d)-> if d.type == "and" then '⋀' else '→')


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

  enter: enter
  update: update
