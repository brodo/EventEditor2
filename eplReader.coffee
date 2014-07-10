parser = require('./JSEPLParser/epl2.js')
createCondition = require('./condition.coffee')
_ = require('lodash')
module.exports = (createEvent, events, connections) -> (epl) ->
  newEvent = (patternFilter) ->
    patternName = pf.name
    name = pf.stream.name
    e = createEvent(name, 10,10)
    conditions = pf.condition
    for parameter in e.parameters
      conditionsOfParameter = _.filter(conditions, (c)-> c[0] == parameter.name)
      for eplCondition in conditionsOfParameter
        condition = createCondition(parameter, 0)
        condition.comparator = eplCondition[1]
        condition.value = eplCondition[2]
        console.log("eplCondition: ", eplCondition)
        console.log("condition: ", condition)
        parameter.conditions.push(condition)

    e.patternName = patternName
    e



  createEventsAndConnections = (pattern) ->
    switch pattern.type # if this exists, that means that there are several events
      when "followedByPattern"
         
        createEventsAndConnections(event) for event in pattern.pattern
      when "orPattern" then "and"
      when "andPattern" then "or"
      else 
        pf = pattern.qualify.guard.expression.patternFilter
        e = newEvent(pf)
        events.push(e)

  try
    parsingResult = parser.parse(epl)
    events.splice(0)
    console.log(parsingResult)
    pattern = parsingResult.body.expression.from.stream.pattern
    createEventsAndConnections(pattern)
  catch error
    console.log("Invalid EPL: ", error)
  
  
