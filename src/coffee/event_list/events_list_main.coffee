RestClient = require('../rest_client')
template = require('../../templates/event_list')
mainDiv = document.querySelector('#event-main')

eventsRestClient = new RestClient(config.eventsBaseUrl,
  config.eventsCollectionUrl, 
  config.eventsItemUrl,
  csrfToken)

surveysRestClient = new RestClient(config.surveysBaseUrl,
  config.surveysCollectionUrl, 
  config.surveysItemUrl,
  csrfToken)

module.exports = ->
  eventsRestClient.getCollection((events)->
    events = events
    mainDiv.innerHTML = template(events: events)
    addDeleteButtonListeners()
    addNameInputListeners()
    addSurveyIdInputListeners()
    addCreateNewEventButtonListener()
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

surveyInputChanged = (event) ->
  id = event.target.dataset.eventid
  eventsRestClient.updateItem(id, survey_id: event.target.value)

addDeleteButtonListeners = -> 
  buttons = _.toArray(mainDiv.querySelectorAll('.deleteButton'))
  buttons.map((b)-> b.onclick = deleteButtonClicked)

addNameInputListeners = ->
  inputs = _.toArray(mainDiv.querySelectorAll('.eventNameInput'))
  inputs.map((i)-> i.oninput = nameInputChanged)

addSurveyIdInputListeners = ->
  inputs = _.toArray(mainDiv.querySelectorAll('.surveyIdInput'))
  inputs.map((i)-> i.oninput = surveyInputChanged)

addCreateNewEventButtonListener = ->
  button = document.querySelector('#newEventButton')
  button.onclick = ->
    nameInput = document.querySelector('#newEventName')
    e = 
      name: nameInput.value
    eventsRestClient.createItem(e, -> location.reload())

# event = 
#   name: "test event #{Math.floor(Math.random()*100)}"
#   definition: "select * from pattern [android.location.Location]"
#   survey_id: 1

# eventsRestClient.createItem(JSON.stringify(event), (r)-> console.log(r))
