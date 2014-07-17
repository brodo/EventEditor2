module.exports = (refreshMain, d3Functions, measures) ->
  enter: (patternGroupEnter) ->
    innerDiv = patternGroupEnter.append('foreignObject')
      .attr('overflow', 'auto')
      .attr('id', (d,i)-> "patternHtml-#{i}")
      .attr('class', 'patternHtml')
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+measures.eventTitleHeight)
      .attr('width', (d)-> d.width-10)
      .attr('height', (d)-> d.height-measures.eventBottomBarHeight-measures.eventTitleHeight)
        .append('xhtml:div')
          .attr('class', 'patternInnerDiv')
          .style('width', (d)-> "#{d.width-10}px")
          .style('height', (d)-> "#{d.height-measures.eventBottomBarHeight-measures.eventTitleHeight}px")

    patternDiv = d3.selectAll('.patternInnerDiv').data(patternList)
      .selectAll('.patternOption')
      .data((d)-> d.options).enter()
      .append('div')
      .attr('class', 'patternOption')

    patternDiv.append('span').text((p)-> p.displayName)
    patternDiv.filter((p)-> p.type == "number")
      .append('input')
      .attr('class', 'pattentInput')
      .attr('type', 'number')

    patternDiv.filter((p)-> p.type == "select")
      .append('select')
      .attr('class', 'pattenInput')
      .selectAll('.pattenSelectOption')
      .data((p)-> p.options).enter()
      .append('option')
      .attr('value', (p)-> p.value)
      .attr('class', 'pattenSelectOption')
      .text((p)-> p.text)

  update: ->

  exit: ->