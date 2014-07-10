
create = (nodes, type, sourceIndex, targetIndex) ->
  nodes: nodes
  target: targetIndex
  source: sourceIndex
  middleHasBeenDragged: false
  type: type
  id: Date.now()
  where:
    visible: false
    value: null
    timeUnit: "seconds"

module.exports = 
  create: create