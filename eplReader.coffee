parser = require('./JSEPLParser/epl2.js')
createCondition = require('./condition.coffee')
Connection = require('./connection.coffee')
_ = require('lodash')
d3 = require('d3')
module.exports = (createEvent, events, connections) -> (epl) ->
  newEvent = (patternFilter) ->
    patternName = patternFilter.name or ''
    name = patternFilter.stream.name
    e = createEvent(name, 10,10)
    conditions = patternFilter.condition
    for parameter in e.parameters
      conditionsOfParameter = _.filter(conditions, (c)-> c[0].eventProperty == parameter.name)
      for eplCondition in conditionsOfParameter
        condition = createCondition(parameter, 0)
        condition.comparator = eplCondition[1][0]
        value = eplCondition[1][1]
        if value.eventProperty #it's a link!
          condition.isLink = true
          propertyArray = value.eventProperty.split('.')
          condition.otherEventProperty = propertyArray[propertyArray.length-1]
          otherEventName = propertyArray[0..-2].join('.')
          console.log("otherName: #{otherEventName}")
          condition.otherEvent = _.find(events, patternName: otherEventName)

        else
          condition.value = value
        console.log("eplCondition: ", eplCondition)
        console.log("condition: ", condition)
        parameter.conditions.push(condition)

    e.patternName = patternName
    e

  newConnection = (type) ->
    fromEvent = events[events.length-2]
    toEvent = events[events.length-1]
    fromNode = fromEvent.followedByRectMiddle()
    toNode = toEvent.followedByRectMiddle()
    middleNode = d3.interpolateObject(fromNode, toNode)(0.5)
    Connection.create([fromNode, middleNode, toNode],
      type, 
      events.length-2,
      events.length-1)



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
        pf = pattern.qualify.guard.expression.patternFilter
        e = newEvent(pf)
        events.push(e)

  try
    parsingResult = parser.parse(epl)
    events.splice(0)
    connections.splice(0)
    console.log(parsingResult)
    pattern = parsingResult.body.expression.from.stream.pattern
    createEventsAndConnections(pattern)
  catch error
    console.log("Invalid EPL: ", error)
  
  
