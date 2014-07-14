_ = require('lodash')
class RestClient
  constructor: (@baseUrl, @collectionUrl, @itemUrl, @csrfToken) ->
    if not _.last(@baseUrl) != '/' then @baseUrl += '/'
    if @collectionUrl[0] == '/' then @collectionUrl = @collectionUrl[1..]
    if @itemUrl[0] == '/' then @itemUrl = @itemUrl[1..]
    @completeCollectionUrl = @baseUrl + @collectionUrl

  getCompleteItemUrlForItemId: (id) -> 
    itemUrlWithId = @itemUrl.replace(':id', id)
    "#{@baseUrl}#{itemUrlWithId}"

  getCollection: (callback)->
    request = new XMLHttpRequest()
    request.onload = -> callback(JSON.parse(@responseText))
    request.open('get', @completeCollectionUrl, true)
    request.setRequestHeader('X-CSRF-Token', @csrfToken)
    request.setRequestHeader('accept', 'application/json; charset=utf-8')
    request.send()

  createItem: (item, callback) ->
    request = new XMLHttpRequest()
    request.onload = -> callback(request)
    request.open('post', @completeCollectionUrl, true)
    request.setRequestHeader('X-CSRF-Token', @csrfToken)
    request.setRequestHeader('Content-Type', 'application/json; charset=utf-8')
    request.send(JSON.stringify(item))

  updateItem: (id, item) ->
    request = new XMLHttpRequest()
    request.open('put', @getCompleteItemUrlForItemId(id), true)
    request.setRequestHeader('X-CSRF-Token', @csrfToken)
    request.setRequestHeader('Content-Type', 'application/json; charset=utf-8')
    request.send(JSON.stringify(item))

  getItem: (id, callback) ->
    request = new XMLHttpRequest()
    request.onload = -> callback(JSON.parse(@responseText))
    request.open('get', @getCompleteItemUrlForItemId(id), true)
    request.setRequestHeader('X-CSRF-Token', @csrfToken)
    request.setRequestHeader('accept', 'application/json; charset=utf-8')
    request.send()
  
  deleteItem: (id) ->
    request = new XMLHttpRequest()
    request.open('delete', @getCompleteItemUrlForItemId(id), true)
    request.setRequestHeader('X-CSRF-Token', @csrfToken)
    request.setRequestHeader('accept', 'application/json; charset=utf-8')
    request.send()



module.exports = RestClient
