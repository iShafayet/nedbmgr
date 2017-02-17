
Polymer {

  is: 'page-update'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.dbUsing
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.apiCalling
  ]

  properties:
    queryString:
      type: String
      value: ->
        object = 
          collection: 'user-info'
        JSON.stringify object, null, 0
      observer: 'queryStringAltered'
    updateString:
      type: String
      value: ->
        object = 
          $set: 
            'testProp': 'test value'
        JSON.stringify object, null, 0
      observer: 'updateStringAltered'
    queryInputErrorMessage:
      type: String
      value: ''
    updateInputErrorMessage:
      type: String
      value: ''
    resultMessage:
      type: String
      value: 'Results will appear here.'

    shouldReturnUpdatedDocList:
      type: Boolean
      value: false

    skip:
      type: Number
      value: 0
    limit:
      type: Number
      value: 20

    lastQueryTimeTaken:
      type: Number
      value: 0
    lastAction:
      type: String
      value: ''
    totalCount:
      type: Number
      value: 0
    docList:
      type: Array
      value: -> []
    selectedDocIndex:
      type: Number
      value: 0
      
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _validateJson: (json)->
    try
      object = JSON.parse json
    catch ex
      return [ ex.message, null ]
    return [ null, object ]

  _validateQueryString: ->
    try
      object = JSON.parse @queryString
    catch ex
      @queryInputErrorMessage = ex.message
      return null
    @queryInputErrorMessage = ''
    return object

  _validateUpdateString: ->
    try
      object = JSON.parse @updateString
    catch ex
      @updateInputErrorMessage = ex.message
      return null
    @updateInputErrorMessage = ''
    return object

  queryStringAltered: ->
    if @queryString.length isnt 0
      @_validateQueryString()

  updateStringAltered: ->
    if @updateString.length isnt 0
      @_validateUpdateString()

  prettifyButtonTapped: (e)->
    if object = @_validateQueryString()
      string = JSON.stringify object, null, 2
      @queryString = string
    if object = @_validateUpdateString()
      string = JSON.stringify object, null, 2
      @updateString = string

  _runQuery: (object, cbfn)->
    @lastAction = 'query'
    token = (new Date).getTime()
    @callQueryApi {
      "apiKey": @domHost.user.apiKey,
      "query": @queryString
      "skip": @skip
      "limit": @limit
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        timeTaken = (new Date).getTime() - token
        cbfn timeTaken, response.data

  _updateResultMessage: ->
    @resultMessage = ''
    msg = "Query took #{@lastQueryTimeTaken}ms. "
    if (@lastAction is 'bulk-delete')
      msg += "Total #{@totalCount} items deleted."
    else if (@lastAction is 'bulk-update' and not @shouldReturnUpdatedDocList)
      msg += "Total #{@totalCount} items matched/affected."
    else
      msg += "showing #{@docList.length} items out of #{@totalCount} starting from index #{@skip}"
    @resultMessage = msg

  runQueryButtonTapped: (e)->
    if object = @_validateQueryString()
      @_runQuery object, (timeTaken, {count, docList})=>
        @lastQueryTimeTaken = timeTaken
        @totalCount = count
        @docList = docList
        @_updateResultMessage()
        @selectedDocIndex = 0

  _bulkUpdate: (cbfn)->
    @lastAction = 'bulk-update'
    token = (new Date).getTime()
    @callBulkUpdateApi {
      "apiKey": @domHost.user.apiKey,
      "query": @queryString
      "updateCommand": @updateString
      "shouldReturnUpdatedDocList": @shouldReturnUpdatedDocList
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        timeTaken = (new Date).getTime() - token
        cbfn timeTaken, response.data

  _bulkDelete: (cbfn)->
    @lastAction = 'bulk-delete'
    token = (new Date).getTime()
    @callBulkDeleteApi {
      "apiKey": @domHost.user.apiKey,
      "query": @queryString
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        timeTaken = (new Date).getTime() - token
        cbfn timeTaken, response.data


  updateAllMatchingQueryButtonTapped: (e)->
    @domHost.showModalPrompt "This will update all the documents that match the query. This is an irreverible action. Are you sure you want to proceed?", (answer)=>
      return unless answer
      if @_validateQueryString() and @_validateUpdateString()
        @_bulkUpdate (timeTaken, {count, docList})=>
          @lastQueryTimeTaken = timeTaken
          @totalCount = count
          if docList
            @docList = docList
          else
            @docList = []
          @_updateResultMessage()
          @selectedDocIndex = 0

  eraseAllMatchingQueryButtonTapped: (e)->
    @domHost.showModalPrompt "This will completely erase all the documents that match the query. This is an irreverible action. Are you sure you want to proceed?", (answer)=>
      return unless answer
      if object = @_validateQueryString()
        @_bulkDelete (timeTaken, { count })=>
          @lastQueryTimeTaken = timeTaken
          @totalCount = count
          @docList = []
          @_updateResultMessage()
          @selectedDocIndex = 0

  $makeDocText: (doc)->
    text = JSON.stringify doc
    object = JSON.parse text
    delete object['_id'] if '_id' of object
    delete object['__nedbmgr__'] if '__nedbmgr__' of object
    text = JSON.stringify object, null, 2
    return text

  _checkOpenedDatabasesAndSelectDefault: ->
    openedDatabaseMeta = (app.db.find 'opened-database-meta')[0]
    if (not openedDatabaseMeta) or openedDatabaseMeta.count is 0
      @domHost.showModalDialog "Please open a database before querying.", =>
        @domHost.navigateToPage '#/'
    else 
      if openedDatabaseMeta.count > 1
        @domHost.showModalDialog "Please note that opening multiple database are not yet supported. The last opened database will be automatically selected."

  navigatedIn: ->
    @_checkOpenedDatabasesAndSelectDefault()



}
