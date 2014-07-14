RestClient = require('../rest_client')
template = require('../../templates/event_list')
mainDiv = document.querySelector('#main')

eventsRestClient = new RestClient(config.eventsBaseUrl,
  config.eventsCollectionUrl, 
  config.eventsItemUrl,
  csrfToken)

module.exports = ->
  eventsRestClient.getCollection((events)->
    events = events
    mainDiv.innerHTML = template(events: events)
    addDeleteButtonListeners()
    addNameInputListeners()
  )

deleteButtonClicked = (event) ->
  toElement = event.toElement
  id = toElement.dataset.eventid
  ulElement = mainDiv.querySelector("ul[data-eventid='#{id}']")
  ulElement.parentElement.removeChild(ulElement);
  eventsRestClient.deleteItem(id)

nameInputChanged = (event) ->
  id = event.target.dataset.eventid
  eventsRestClient.updateItem(id, name: event.target.value)


addDeleteButtonListeners = -> 
  buttons = _.toArray(mainDiv.querySelectorAll('.deleteButton'))
  buttons.map((b)-> b.onclick = deleteButtonClicked)

addNameInputListeners = ->
  inputs = _.toArray(mainDiv.querySelectorAll('.eventName'))
  inputs.map((i)-> i.oninput = nameInputChanged)

# event = 
#   name: "test event #{Math.floor(Math.random()*100)}"
#   definition: "select * from pattern [android.location.Location]"
#   survey_id: 1

# eventsRestClient.createItem(JSON.stringify(event), (r)-> console.log(r))
