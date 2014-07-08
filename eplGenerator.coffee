_ = require('lodash')

calculateWeight = (eventList, connectionList, event, weight) ->
  connection = _.find(connectionList, source: eventList.indexOf(event))
  if connection
    nextNode = eventList[connection.target]
    return calculateWeight(eventList, connectionList, nextNode, weight+1)
  weight


conditionToEpl = (condition, parameter) ->
  if condition.isLink
    "#{condition.combinator or ''} #{parameter.name} #{condition.comparator} #{condition.otherEvent.patternName}.#{condition.otherEventProperty}"  
  else
    "#{condition.combinator or ''} #{parameter.name} #{condition.comparator} #{condition.value or ''} "
parameterToEpl = (parameter) ->
  conditions = (conditionToEpl(condition, parameter) for condition in parameter.conditions)
  conditions.join('')

eventToEpl = (event, index) ->
  attributesList = (parameterToEpl(parameter) for parameter in event.parameters)
  attributes = "(#{attributesList.join(' ')}) "
  index = eventList.indexOf(event)
  connectionSource = _.find(connectionList, source: index)
  connectionTarget = _.find(connectionList, target: index)
  isSourceOfWhereConnection = connectionSource and connectionSource.where.value
  isTargetOfWhereConnection = connectionTarget and connectionTarget.where.value
  openBracket = if isSourceOfWhereConnection then '(' else ''
  closedBracket = if isTargetOfWhereConnection then ')' else ''
  whereClause = if isTargetOfWhereConnection
    " where timer:within(#{connectionTarget.where.value} #{connectionTarget.where.timeUnit}) " 
  else 
    ''
  "#{openBracket}#{event.patternName}=#{event.name}#{attributes}#{whereClause}#{closedBracket} #{connectionSource?.type or 'or'} "

module.exports = (eventList, connectionList)->
  sortedEventList = _.sortBy(eventList, (e) -> calculateWeight(eventList, connectionList, e, 0) * -1)
  eventEplList = (eventToEpl(event) for event, index in sortedEventList)
  pattern = eventEplList.join('')
  "select * from pattern [#{pattern[0..-5]}]"
