module.exports = (eventList, connectionList)->
  conditionToEpl = (condition, parameter) ->
    "#{condition.combinator or ''} #{parameter.name} #{condition.comparator} #{condition.value or ''} "
  parameterToEpl = (parameter) ->
    conditions = (conditionToEpl(condition, parameter) for condition in parameter.conditions)
    conditions.join('')

  eventToEpl = (event) ->
    console.log(event)
    attributesList = (parameterToEpl(parameter) for parameter in event.parameters )
    attributes = "(#{attributesList.join(' ')})"
    "#{event.patternName}=#{event.name}#{attributes}"
  eventEplList = (eventToEpl(event) for event in eventList)
  pattern = eventEplList.join(' ')

  "select * from pattern [#{pattern}]"
