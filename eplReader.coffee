parser = require('./JSEPLParser/epl2.js')

createEventsAndConnections = (pattern) ->
  if pattern.type # if this exists, that means that there are several events
    pf = pattern.qualify.guard.expression.patternFilter
    patternName = pf.name
    name = pf.stream.name

    event
      id: Date.now()
      name: name
      patternName:

  events: []
  connections: []




module.exports = (createEvent, events, connections) -> (epl) ->
  try
    parsingResult = parser.parse(epl)
    pattern = parsingResult.body.expression.from.stream.pattern

    window.pattern = pattern
    console.log(pattern)
  catch e
    console.log("Invalid EPL")
  
  
