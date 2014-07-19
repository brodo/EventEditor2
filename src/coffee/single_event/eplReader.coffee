parser = require('../../JSEPLParser/epl2.js')
createCondition = require('./condition.coffee')
Connection = require('./connection.coffee')
_ = require('lodash')
d3 = require('d3')
module.exports = (createEvent, createPattern, events, patterns, connections) -> (epl) ->
  windows = []
  newCoordinates = ->
    x: ((events.length + patterns.length) * 260) + 135
    y: 130
  newEvent = (patternFilter) ->
    patternName = patternFilter.name or ''
    name = patternFilter.stream.name
    coord = newCoordinates()
    e = createEvent(name, coord.x, coord.y, true)
    conditions = patternFilter.condition
    for parameter in e.parameters
      conditionsOfParameter = _.filter(conditions, (c)-> c[0].eventProperty == parameter.name)
      for eplCondition in conditionsOfParameter
        condition = createCondition(parameter, 0)
        condition.comparator = eplCondition[1].comperator
        value = eplCondition[1].value
        if value.eventProperty #it's a link!
          condition.isLink = true
          propertyArray = value.eventProperty.split('.')
          condition.otherEventProperty = propertyArray[propertyArray.length-1]
          otherEventName = propertyArray[0..-2].join('.')
          console.log("otherEvent ", otherEventName)
          condition.otherEvent = _.find(events, patternName: otherEventName)

        else
          condition.value = value
        parameter.conditions.push(condition)

    e.patternName = patternName
    e

  newPattern = (qualify) ->
    name = qualify.patternType
    coord = newCoordinates()
    p = createPattern(name, coord.x, coord.y, true)

    for key, value of qualify
      if key == "patternType" then continue
      option = _.find(p.options, name: key)
      option.value = value.join('')
    p


  newConnection = (type) ->
    fromWindow = windows[windows.length-2]
    toWindow = windows[windows.length-1]
    fromNode = fromWindow.followedByRectMiddle()
    toNode = toWindow.followedByRectMiddle()
    middleNode = d3.interpolateObject(fromNode, toNode)(0.5)
    Connection.create([fromNode, middleNode, toNode],
      type, 
      fromWindow.id,
      toWindow.id)



  createEventsAndConnections = (pattern) ->
    switch pattern.type # if this exists, that means that there are several events
      when "followedByPattern"
        createEventsAndConnections(event) for event in pattern.pattern
        connection = newConnection('->')
        connections.push(connection)
      when "andPattern" 
        createEventsAndConnections(event) for event in pattern.pattern
        connection = newConnection('and')
        connections.push(connection)
      when "orPattern"
        createEventsAndConnections(event) for event in pattern.pattern
      else 
        # TODO: mark patterns with a comment
        if pattern?.qualify?.guard?.expression?.patternFilter #it's an event
          pf = pattern.qualify.guard.expression.patternFilter
          e = newEvent(pf)
          events.push(e)
          windows.push(e)
          

        if pattern?.qualify?.patternType # it's a predefined pattern
          p = newPattern(pattern.qualify)
          patterns.push(p)
          windows.push(p)
          



  parsingResult = null

  try
    parsingResult = parser.parse(epl)
  catch error
    console.log("Invalid EPL: ", error)
  
  if parsingResult
    events.splice(0)
    patterns.splice(0)
    connections.splice(0)
    windows.splice(0)
    pattern = parsingResult.body.expression.from.stream.pattern
    createEventsAndConnections(pattern)
  
  
  
