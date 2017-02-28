
Polymer {

  is: 'page-search'

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
    queryInputErrorMessage:
      type: String
      value: ''
    resultMessage:
      type: String
      value: 'Results will appear here.'
    skip:
      type: Number
      value: 0
    limit:
      type: Number
      value: 20
    lastQueryTimeTaken:
      type: Number
      value: 0
    totalCount:
      type: Number
      value: 0
    docList:
      type: Array
      value: -> []
    selectedDocIndex:
      type: Number
      value: 0

  parseJsonForQuery: (json)->
    return JSON.parse json
      
  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _validateJson: (json)->
    try
      object = @parseJsonForQuery json
    catch ex
      return [ ex.message, null ]
    return [ null, object ]

  _validateQueryString: ->
    try
      object = @parseJsonForQuery @queryString
    catch ex
      @queryInputErrorMessage = ex.message
      return null
    @queryInputErrorMessage = ''
    return object

  queryStringAltered: ->
    if @queryString.length isnt 0
      @_validateQueryString()

  prettifyButtonTapped: (e)->
    if object = @_validateQueryString()
      string = JSON.stringify object, null, 2
      @queryString = string

  _runQuery: (object, cbfn)->
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
    msg += "showing #{@docList.length} items out of #{@totalCount} starting from index #{@skip}"
    @resultMessage = msg

  runQueryButtonTapped: (e)->
    if object = @_validateQueryString()
      @_runQuery object, (timeTaken, {count, docList})=>
        @lastQueryTimeTaken = timeTaken
        @totalCount = count

        for doc in docList
          doc.__nedbmgr__ = 
            isModified: false
            refreshKey: 0
            errorMessage: ''
            value: null
            isRemovedFromRemoteServer: false
        @docList = docList

        @_updateResultMessage()
        @selectedDocIndex = 0

  docCardTapped: (e)->
    { docIndex } = e.model
    @selectedDocIndex = docIndex
    
  docInputKeyPress: (e)->
    { docIndex } = e.model
    doc = @docList[docIndex]
    @set "docList.#{docIndex}.__nedbmgr__.isModified", true
    value = e.target.value
    @set "docList.#{docIndex}.__nedbmgr__.value", value
    [ err, object ] = @_validateJson value
    if err
      @set "docList.#{docIndex}.__nedbmgr__.errorMessage", err
    else
      @set "docList.#{docIndex}.__nedbmgr__.errorMessage", ''

  resetDocButtonTapped: (e)->
    { docIndex } = e.model
    doc = @docList[docIndex]
    refreshKey = @get "docList.#{docIndex}.__nedbmgr__.refreshKey"
    refreshKey += 1
    @set "docList.#{docIndex}.__nedbmgr__.refreshKey", refreshKey
    @set "docList.#{docIndex}.__nedbmgr__.isModified", false
    @set "docList.#{docIndex}.__nedbmgr__.errorMessage", ''

  removeDocButtonTapped: (e)->
    { docIndex } = e.model
    doc = @docList[docIndex]
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      return unless answer
      @callRemoveDocApi {
        "apiKey": @domHost.user.apiKey,
        "id": doc._id
      }, (err, response)=>
        if response.statusCode isnt 200
          @domHost.showModalDialog response.message
        else
          @domHost.showToast 'Delete successful.'
          @set "docList.#{docIndex}.__nedbmgr__.isRemovedFromRemoteServer", true

  saveDocButtonTapped: (e)->
    { docIndex } = e.model
    doc = @docList[docIndex]
    @domHost.showModalPrompt "Are you sure?", (answer)=>
      return unless answer
      
      newDoc = @parseJsonForQuery (@get "docList.#{docIndex}.__nedbmgr__.value")
      newDoc._id = doc._id

      @callUpdateDocApi {
        "apiKey": @domHost.user.apiKey,
        "doc": newDoc
      }, (err, response)=>
        if response.statusCode isnt 200
          @domHost.showModalDialog response.message
        else
          doc.__nedbmgr__.refreshKey += 1
          doc.__nedbmgr__.isModified = false
          newDoc.__nedbmgr__ = doc.__nedbmgr__
          @set "docList.#{docIndex}", newDoc
          @domHost.showToast 'Update successful.'

  $makeDocText: (doc)->
    text = JSON.stringify doc
    object = @parseJsonForQuery text
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

  shortcutFirstPageTapped: (e)->
    @skip = 0
    @runQueryButtonTapped()

  shortcutPrevPageTapped: (e)->
    @skip = Math.max 0, ((parseInt @skip) - (parseInt @limit))
    @runQueryButtonTapped()

  shortcutNextPageTapped: (e)->
    @skip = ((parseInt @skip) + (parseInt @limit))
    @runQueryButtonTapped()

}
