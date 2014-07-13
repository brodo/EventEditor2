config = require('../../data/test_config.json')
RestClient = require('./rest_client')
template = require('../../templates/events')
mainDiv = document.querySelector('#main')

csrfToken = 't1jpiODT3yO/Gatbgu+tKj1HiYMn02b+lejnbFlmc5c='
console.clear()

eventsRestClient = new RestClient(config.eventsBaseUrl,
  config.eventsCollectionUrl, 
  config.eventsItemUrl,
  csrfToken)

eventsRestClient.getCollection((events)->
  events = JSON.parse(events)
  mainDiv.innerHTML = template(events: events)
)

# event = 
#   name: "test event 3"
#   definition: "select * from pattern [android.location.Location]"
#   survey_id: 1

# eventsRestClient.createItem(JSON.stringify(event), (r)-> console.log(r))
