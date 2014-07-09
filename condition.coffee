module.exports = (parameter, eventIndex) ->
  length = parameter.conditions.length 
  
  comparators: parameter.comparators
  type: parameter.type
  value: null
  combinator: (if length == 0 then null else 'and')
  width: parameter.width
  comparator: parameter.comparators[0]
  id: Date.now()
  isLink: false
  index: length
  parentIndex: eventIndex
  
