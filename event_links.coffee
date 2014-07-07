module.exports = () ->
  enter = (conditionsEnter) ->

    conditionsEnter
      .append('span')
        .attr('class', 'linkSelectors')
    
    # Select element for selecting the other event
    conditionsEnter.selectAll('.linkSelectors')
      .append('select')
      .attr('class', 'eventSelector')
      .on('change', (d)->
        id = parseInt(@value,10)
        d.otherEvent = eventList.filter((e)-> e.id == id)[0]
        sel = d3.selectAll('.eventPropertySelector')
          .selectAll('.otherEventProperty')
          .data(d.otherEvent.parameters, (d)-> d.name)
        sel.exit().remove()
        sel.enter()
          .append('option')
          .attr('class', 'otherEventProperty')
          .attr('value', (p)-> p.id)
          .text((p)-> p.displayName)
      )

    # Option elements for each other event
    d3.selectAll('.eventSelector')
      .selectAll('.otherEventNames')
      .data(((d)-> 
        eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id)),
        (d) -> d.id
      ).enter()
      .append('option')
        .attr('class', 'otherEventNames')
        .attr('value', (d)-> d.id)
        .text((d)-> d.patternName)

    # Select element for selecting the other events parameter
    conditionsEnter.filter((c)-> c.isLink).selectAll('.linkSelectors')
      .append('select')
      .attr('class', 'eventPropertySelector')

    # Option elements for each parameter of the other event
    conditionsEnter
      .filter((c)-> c.isLink)
      .selectAll('.eventPropertySelector')
      .selectAll('.otherEventProperty')
      .data((d)->d.otherEvent.parameters)
      .enter()
      .append('option')
      .attr('class', 'otherEventProperty')
      .attr('value', (d)-> d.id)
      .text((d)-> d.displayName)
  update = ->
    # Update pattern name in event select element
    d3.selectAll('.eventSelector').selectAll('.otherEventNames')
      .data((d)-> eventList.filter((e)-> e.parameters[d.parentIndex]?.conditions[d.index]?.id != d.id))
      .text((d)-> d.patternName)

  enter: enter
  update: update