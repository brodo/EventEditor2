RestClient = require('../rest_client')
template = require('../../templates/event_list')
mainDiv = document.querySelector('#main')

eventsRestClient = new RestClient(config.eventsBaseUrl,
  config.eventsCollectionUrl, 
  config.eventsItemUrl,
  csrfToken)

module.exports = ->
  eventsRestClient.getCollection((events)->
    events = JSON.parse(events)
    mainDiv.innerHTML = template(events: events)
    addDeleteButtonListeners() 
  )

deleteButtonClicked = (event) ->
  toElement = event.toElement
  id = toElement.dataset.eventid
  ulElement = mainDiv.querySelector("ul[data-eventid='#{id}']")
  ulElement.parentElement.removeChild(ulElement);
  eventsRestClient.deleteItem(id)

addDeleteButtonListeners = -> 
  buttons = _.toArray(mainDiv.querySelectorAll('.deleteButton'))
  buttons.map((b)-> b.onclick = deleteButtonClicked )

event = 
  name: "test event #{Math.floor(Math.random()*10)}"
  definition: "select * from pattern [android.location.Location]"
  survey_id: 1

eventsRestClient.createItem(JSON.stringify(event), (r)-> console.log(r))
