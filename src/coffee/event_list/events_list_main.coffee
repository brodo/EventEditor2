template = require('../../templates/events')
mainDiv = document.querySelector('#main')
mainDiv.innerHTML = template(name: "test")
eventGetRootUrl = 'https://explore-sta.datarella.com/api/v1/events' 
authenticationToken = 'GNU1wNChmCBNZB1fC8id'
eventGetUrl = "#{eventGetRootUrl}?authentication_token=#{authenticationToken}"

getEvents = (url)->
  request = new XMLHttpRequest()
  request.onload = -> console.log(JSON.parse(@responseText))
  request.open('get', url, true)
  request.send()

getEvents(eventGetUrl)