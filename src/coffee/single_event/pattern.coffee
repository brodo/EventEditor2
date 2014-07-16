module.exports = (patterns, measures, getMainRect) -> (patternName, x,y, relative) ->
  d = _.find(patterns, name: patternName)
  data = _.cloneDeep(d)
  data.id = Math.floor(Math.random()*1e15)
  left = if relative then 0 else getMainRect().left
  data.x = Math.max(0,x-left-125)
  top = if relative then 0 else getMainRect().top
  data.y  = Math.max(0,y-top-125)
  data.width = measures.eventWidth
  data.height = measures.eventHeight
  data.andRect = -> 
    x: @x + 5
    y: @y + @height - measures.eventTitleHeight + 5
  data.andRectMiddle = ->
    x: @andRect().x + measures.andCombinatorButtonWidth / 2
    y: @andRect().y + measures.andCombinatorButtonHeight / 2
  data.followedByRect = -> 
    x: @x + 5 + measures.andCombinatorButtonWidth + 5
    y: @y + @height - measures.eventTitleHeight + 5
  data.followedByRectMiddle = ->
    x: @followedByRect().x + measures.followedByCombinatorButtonWidth / 2
    y: @followedByRect().y + measures.followedByCombinatorButtonHeight / 2

  data