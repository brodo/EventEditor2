util = require('./util.coffee')
module.exports = (className, refreshMain, d3Functions, remove, titleHeight) ->
  closeIconPoints = "438.393,374.595 319.757,255.977 438.378,137.348 
    374.595,73.607 255.995,192.225 137.375,73.622 73.607,137.352 192.246,255.983 
    73.622,374.625 137.352,438.393 256.002,319.734 374.652,438.378"

  dragmove = (data) ->
    data.x = Math.max(0, d3.event.x)
    data.y = Math.max(0, d3.event.y)
    d3.select(@.parentElement).moveToFront()
    refreshMain()
    d3Functions.update()

  drag = d3.behavior.drag()
    .origin(util.id)
    .on("drag", dragmove)

  enter = (groupEnter)->
    util.debug and console.log("%c[WindowTitle] %cEnter", util.greenBold, util.bold)
    
    groupEnter.append('rect')
      .attr('class', "#{className}TitleRect")
      .attr('width', (d)-> d.width)
      .attr('height', titleHeight)
      .attr('x', (d)-> d.x)
      .attr('y', (d)-> d.y)
      .on('click', (d)-> d3.select(@parentElement).moveToFront())
      .call(drag)

    groupEnter.append('polygon')
      .attr('class', 'closeButton')
      .attr('points', closeIconPoints)
      .attr('transform', (d)-> "translate(#{d.x+d.width-30},#{d.y+3}) scale(0.05)")
      .on('click', remove)

    groupEnter.append('text')
      .attr('class', "#{className}Title")
      .attr('y', (d)-> d.y + 25)
      .attr('x', (d) -> d.x + d.width/2)
      .attr('width', (d)-> d.width-10)
      .text((d)-> d.displayName)
      .on('click', (d)-> d3.select(@parentElement).moveToFront())
      .call(drag)

  update = ->
    d3.selectAll(".#{className}TitleRect")
      .attr('width', (d)-> d.width)
      .attr('x', (d) -> d.x)
      .attr('y', (d) -> d.y)  

    d3.selectAll('.closeButton')
      .attr('transform', (d)-> "translate(#{d.x+d.width-30},#{d.y+3}) scale(0.05)")

    d3.selectAll(".#{className}Title")
      .attr('y', (d)-> d.y + 25)
      .attr('x', (d) -> d.x + d.width/2)
      .attr('width', (d)-> d.width-10)

  enter: enter
  update: update