parser = require('./JSEPLParser/epl2.js')
_ = require('lodash')
module.exports = (createEvent, events, connections) -> (epl) ->
  createEventsAndConnections = (pattern) ->
    console.log(pattern)
    events.splice(0)
    if not pattern.type # if this exists, that means that there are several events
      pf = pattern.qualify.guard.expression.patternFilter
      patternName = pf.name
      name = pf.stream.name
      e = createEvent(name, 10,10)
      conditions = pf.condition
      for parameter in e.parameters

      e.patternName = patternName
      events.push(e)

  
  try
    parsingResult = parser.parse(epl)
    pattern = parsingResult.body.expression.from.stream.pattern
    createEventsAndConnections(pattern)
  catch error
    console.log("Invalid EPL: ", error)
  
  
