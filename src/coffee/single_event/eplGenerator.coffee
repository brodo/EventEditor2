_ = require('lodash')

calculateWeight = (eventList, connectionList, event, weight) ->
  sourceConnection = _.find(connectionList, source: eventList.indexOf(event))
  if sourceConnection
    nextNode = eventList[sourceConnection.target]
    return calculateWeight(eventList, connectionList, nextNode, weight+1)
  targetConnection = _.find(connectionList, target: eventList.indexOf(event))
  if targetConnection # node is target, but no source. So it must be the last node
    weight = 0.5
  weight


conditionToEpl = (condition, parameter) ->
  if condition.isLink
    "#{condition.combinator or ''} #{parameter.name} #{condition.comparator} #{condition.otherEvent.patternName}.#{condition.otherEventProperty}"  
  else
    "#{condition.combinator or ''} #{parameter.name} #{condition.comparator} #{condition.value or ''} "
parameterToEpl = (parameter) ->
  conditions = (conditionToEpl(condition, parameter) for condition in parameter.conditions)
  conditions.join('')

toEpl = (thing) ->
  if thing.type == "pattern" then patternToEpl(thing) else eventToEpl(thing)

patternToEpl = (pattern) ->
  template = pattern.template
  for option in pattern.options
    template = template.replace("{{#{option.name}}}", option.value or '')
  console.log(template)
  "#{template} or "

eventToEpl = (event) ->
  attributesList = (parameterToEpl(parameter) for parameter in event.parameters)
  attributes = "(#{attributesList.join(' ')}) "
  index = eventList.indexOf(event)
  connectionSource = _.find(connectionList, source: event.id)
  connectionTarget = _.find(connectionList, target: event.id)
  isSourceOfWhereConnection = connectionSource and connectionSource.where.value
  isTargetOfWhereConnection = connectionTarget and connectionTarget.where.value
  openBracket = if isSourceOfWhereConnection then '(' else ''
  closedBracket = if isTargetOfWhereConnection then ')' else ''
  whereClause = if isTargetOfWhereConnection
    " where timer:within(#{connectionTarget.where.value} #{connectionTarget.where.timeUnit}) " 
  else 
    ''
  equals = if event.patternName == '' then '' else '='
  """#{openBracket}#{event.patternName}#{equals}#{event.name}#{attributes}#{whereClause}#{closedBracket} #{connectionSource?.type or 'or'} """

module.exports = (eventList, patternList, connectionList)->
  combinedList = eventList.concat(patternList)
  sortedCombinedList = _.sortBy(combinedList, (e) -> calculateWeight(combinedList, connectionList, e, 0) * -1)
  eplList = (toEpl(element) for element in sortedCombinedList)
  pattern = eplList.join('')
  "select * from pattern [#{pattern[0..-5]}]"
