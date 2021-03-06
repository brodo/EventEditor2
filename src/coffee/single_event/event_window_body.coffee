util = require('./util.coffee')
Links = require('./event_links.coffee')
createCondition = require('./condition.coffee')

module.exports = (refreshMain, d3Functions, measures) ->
  links = Links(d3Functions)
  enter = (eventGroupEnter) ->
    innerDiv = eventGroupEnter.append('foreignObject')
      .attr('overflow', 'auto')
      .attr('id', (d,i)-> "eventHtml-#{i}")
      .attr('class', 'eventHtml')
      .attr('x', (d) -> d.x+5)
      .attr('y', (d) -> d.y+measures.eventTitleHeight)
      .attr('width', (d)-> d.width-10)
      .attr('height', (d)-> d.height-measures.eventBottomBarHeight-measures.eventTitleHeight)
        .append('xhtml:div')
          .attr('class', 'eventInnerDiv')
          .style('width', (d)-> "#{d.width-10}px")
          .style('height', (d)-> "#{d.height-measures.eventBottomBarHeight-measures.eventTitleHeight}px")
    parameters = innerDiv.append('div').attr('class', 'parameters')

    parameterEnter = parameters.selectAll('.parameter').data((d)-> d.parameters ).enter()
      .append('div').attr('class', 'parameter')
    
    parameterEnter.append('label')
      .text((d) -> if d.unit != null and d.unit != '' then "#{d.displayName} (#{d.unit}): " else "#{d.displayName}: ")
      .attr('for', (d,i) -> "param-#{i}")

    parameterEnter.append('span')
      .attr('class', "paramMiddle")

    parameterEnter.append('button')
      .attr('class', "addConditionButton")
      .text('+')
      .on('click', (d,i)->
        length = d.conditions.length 
        d.conditions.push(
          createCondition(d,i)
        )
        d3Functions.enter()
      )
  
    parameterEnter.append('button')
      .attr('class', "addLinkConditionButton")
      .attr('disabled', true)
      .text('o')
      .on('click', (d, i)->
        length = d.conditions.length
        otherEvent = eventList.filter((e)-> e.id != d.parentId)[0]
        d.conditions.push(
          comparators: d.comparators
          type: d.type
          value: null
          combinator: (if length == 0 then null else 'and')
          width: d.width
          comparator: d.comparators[0]
          id: Date.now()
          isLink: true
          index: length
          parentIndex: i
          otherEvent: otherEvent
          otherEventProperty: otherEvent.parameters[0].name 
        )
        d3Functions.enter()
      )
    d3.selectAll('.addLinkConditionButton').filter(()-> eventList.length > 1)
      .attr('disabled', null)
    
    conditionsEnter = d3.selectAll('.paramMiddle').selectAll('.condition')
      .data((d)-> d.conditions).enter()
        .append('div').attr('class', 'condition')

    conditionsEnter.filter((d)-> d.combinator != null)
      .append('select')
        .attr('class',  'combinator')
        .on('change', (d) ->
          d.combinator = @value
          d3Functions.update()
        )
        .selectAll('.combinatorOption')
          .data((d)-> ['And', 'Or'])
          .enter()
          .append('option')
            .attr('class', 'combinatorOption')
            .attr('value', (d)->d)
            .text((d)->d)



    conditionsEnter
      .append('select')
        .attr('class', 'comparatorSelect')
        .property('value', (d)-> d.comparator)
        .on('change', (d) -> 
          d.comparator = @value
          d3Functions.update()
        )
        .selectAll('.comparatorOption')
          .data((d)-> d.comparators)
          .enter()
          .append('option')
            .attr('class', 'comparatorOption')
            .attr('value', (d)-> d)
            .text((d) -> d)

    conditionsEnter.filter((d)-> !d.isLink).append('input')
      .attr('type', (d)-> d.type)
      .property('value', (d)-> d.value)
      .attr('class', 'valueInput')
      .style('width', (d) -> "#{d.width}px")
      .on('input', (d)-> 
        d.value = @value
        d3Functions.update()
      )

    links.enter(conditionsEnter)

    conditionsEnter.append('button')
      .attr('class', 'deleteCondition')
      .text('-')
      .on('click', (d,i) ->
        d3.select(@parentNode.parentNode).datum().conditions.splice(i,1)
        d3Functions.update()
        exit()
      )

    

  update = ->
    links.update()
    d3.selectAll('.comparatorSelect')
      .property('value', (d)-> 
        d.comparator
      )

  exit = ->
    events = d3.selectAll('.event').data(eventList, (d)-> d.id)
    events.selectAll('.parameter').data((d)-> d.parameters)
      .selectAll('.condition').data(((d)-> d.conditions), ((d)-> d.id))
      .exit()
      .remove()

  enter: enter
  update: update
  exit: exit