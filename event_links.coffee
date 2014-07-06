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
        enter(conditionsEnter)
        exit()
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
    conditionsEnter.selectAll('.linkSelectors')
      .append('select')
      .attr('class', 'eventPropertySelector')

    # Option elements for each parameter of the other event
    conditionsEnter
      .selectAll('.eventPropertySelector')
      .data((d)->d.otherEvent.parameters)
      .append('option')
      .attr('class', 'otherEventProperty')
      .attr('value', (d)-> d.id)
      .text((d)-> d.displayName)

  exit = ->
    d3.selectAll('.eventPropertySelector')
      .selectAll('.otherEventProperty')
      .data((d)->d.otherEvent.parameters)
      .exit()
      .remove()
   


  enter:enter