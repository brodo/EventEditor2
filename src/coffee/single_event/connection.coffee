create = (nodes, type, sourceId, targetId) ->
  nodes: nodes
  source: sourceId
  target: targetId
  middleHasBeenDragged: false
  type: type
  id: Math.floor(Math.random()*1e15)
  where:
    visible: false
    value: null
    timeUnit: "seconds"


module.exports = 
  create: create