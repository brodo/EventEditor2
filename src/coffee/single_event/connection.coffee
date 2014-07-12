create = (nodes, type, sourceIndex, targetIndex) ->
  nodes: nodes
  target: targetIndex
  source: sourceIndex
  middleHasBeenDragged: false
  type: type
  id: Math.floor(Math.random()*1e15)
  where:
    visible: false
    value: null
    timeUnit: "seconds"


module.exports = 
  create: create