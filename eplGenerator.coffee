_ = require('lodash')

calculateWeight = (eventList, connectionList, event, weight) ->
  connection = _.find(connectionList, source: eventList.indexOf(event))
  if connection
    nextNode = eventList[connection.target]
    return calculateWeight(eventList, connectionList, nextNode, weight+1)
  weight


conditionToEpl = (condition, parameter) ->
  "#{condition.combinator or ''} #{parameter.name} #{condition.comparator} #{condition.value or ''} "
parameterToEpl = (parameter) ->
  conditions = (conditionToEpl(condition, parameter) for condition in parameter.conditions)
  conditions.join('')

eventToEpl = (event, index) ->
  attributesList = (parameterToEpl(parameter) for parameter in event.parameters)
  attributes = "(#{attributesList.join(' ')}) "
  index = eventList.indexOf(event)
  connection = _.find(connectionList, source: index)

  "#{event.patternName}=#{event.name}#{attributes} #{connection?.type or 'or'} "


module.exports = (eventList, connectionList)->
  sortedEventList = _.sortBy(eventList, (e) -> calculateWeight(eventList, connectionList, e, 0) * -1)
  eventEplList = (eventToEpl(event) for event, index in sortedEventList)

  pattern = eventEplList.join('')

  "select * from pattern [#{pattern[0..-5]}]"
