
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
        JSON.stringify object, null, 2
      # observer: 'queryStringAltered'
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
    isLoadExistingAreaExpanded:
      type: Boolean
      value: false
    storedQuery:
      type: Object
      value: -> {
        body: ''
        nameAndTagString: ''
        type: 'cson'
        idOnServer: null
      }
    storedQueryTagList:
      type: Array
      value: -> []
    storedQueryTagMap:
      type: Object
      value: -> {}
    storedQueryList:
      type: Array
      value: -> []
    filterStoredQueryTagList: 
      type: Array
      value: -> []
    filteredStoredQueryList: 
      type: Array
      value: -> []
    queryStringTypeSelectedIndex:
      type: Number
      value: ->
        index = lib.localStorage.getItem '--nedbmgr-query-type-index'
        return (if index isnt null then (parseInt index) else 0)
      observer: 'queryStringTypeSelectedIndexChanged'

  observers: [
    'queryStringAltered(queryString, queryStringTypeSelectedIndex)'
  ]

  queryStringTypeSelectedIndexChanged: ->
    index = lib.localStorage.getItem '--nedbmgr-query-type-index'
    if index isnt (''+@queryStringTypeSelectedIndex)
      lib.localStorage.setItem '--nedbmgr-query-type-index', @queryStringTypeSelectedIndex
    @storedQuery.type = ['cson', 'json'][@queryStringTypeSelectedIndex]

  $in: (item, list)-> item in list

  ## ========= Save/Load ========= ##

  storedQueryLoadIconTapped: (e)->
    @isLoadExistingAreaExpanded = false
    { storedQuery } = e.model
    @set 'storedQuery', storedQuery
    @set 'queryString', storedQuery.body
    if storedQuery.type is 'cson'
      @queryStringTypeSelectedIndex = 0
    else
      @queryStringTypeSelectedIndex = 1

  _filterStoredQueryList: ->
    if @filterStoredQueryTagList.length is 0
      @set 'filteredStoredQueryList', []
      return
    filteredStoredQueryList = []
    for tag in @filterStoredQueryTagList
      tag = '#' + tag
      for storedQuery in @storedQueryList
        if (storedQuery.nameAndTagString.indexOf tag) > -1 or tag is '#[ALL]'
          filteredStoredQueryList.push storedQuery
      filteredStoredQueryList = lib.array.unique filteredStoredQueryList
    @set 'filteredStoredQueryList', filteredStoredQueryList

  loadExistingExpandPressed: (e)->
    @isLoadExistingAreaExpanded = true

  loadExistingCollapsePressed: (e)->
    @isLoadExistingAreaExpanded = false

  _fetchStoredQueryList: (cbfn)->
    @callFetchStoredQueryListApi {
      "apiKey": @domHost.user.apiKey
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        cbfn response.data.queryList
        return

  _loadAndDisplayStoredQueryList: ->
    @_fetchStoredQueryList (queryList)=>
      tagMap = {}
      for detailedQueryObject in queryList
        detailedQueryObject.idOnServer = detailedQueryObject._id
        delete detailedQueryObject._id
        { nameAndTagString } = detailedQueryObject
        wordArray = nameAndTagString.split ' '
        for word in wordArray
          if word.charAt(0) is '#'
            word = word.substr 1
            unless word of tagMap
              tagMap[word] = []
            tagMap[word].push detailedQueryObject
      storedQueryTagList = (Object.keys tagMap)
      storedQueryTagList.push '[ALL]'
      @set 'storedQueryTagMap', tagMap
      @set 'storedQueryTagList', storedQueryTagList
      @set 'storedQueryList',  queryList
      @set 'filterStoredQueryTagList', []
      @_filterStoredQueryList()

  $getStoredQueryTaggedCount: (storedQueryTagMap, tag)->
    if tag is '[ALL]'
      return @storedQueryList.length
    return try storedQueryTagMap[tag].length catch ex then 0

  storedQueryTagTapped: (e)->
    { tag } = e.model
    if tag in @filterStoredQueryTagList
      index = @filterStoredQueryTagList.indexOf tag
      @splice 'filterStoredQueryTagList', index, 1
    else
      @push 'filterStoredQueryTagList', tag
    @_filterStoredQueryList()

  storedQueryNamingHelpIconTapped: (e)->
    message = 'Name your query. Please use a #Hashtag to make it filterable. Such as "Get User List #MyProject #User"'
    @domHost.showModalDialog message

  storedQuerySaveButtonTapped: (e)->
    detailedQueryObject = {
      idOnServer: @storedQuery.idOnServer
      type: @storedQuery.type
      body: @queryString
      nameAndTagString: @storedQuery.nameAndTagString
    }
    
    @callSaveQueryInQueryStoreApi {
      "apiKey": @domHost.user.apiKey
      detailedQueryObject
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        storedQuery = response.data.detailedQueryObject
        storedQuery.idOnServer = storedQuery._id
        delete storedQuery['_id']
        @set 'storedQuery', storedQuery
      @_loadAndDisplayStoredQueryList()

  storedQueryDeleteButtonTapped: (e)->
    @callDeleteQueryFromQueryStoreApi {
      "apiKey": @domHost.user.apiKey
      "id": @storedQuery.idOnServer
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        @domHost.showToast "Stored query was deleted."
        @set 'storedQuery.idOnServer', null
      @_loadAndDisplayStoredQueryList()

  ## ========= - ========= ##

  parseQueryStringForQuery: (queryString)->
    if @queryStringTypeSelectedIndex is 0
      return CoffeeScript.eval queryString
    else
      return JSON.parse queryString

  arrowBackButtonPressed: (e)->
    @domHost.navigateToPreviousPage()

  _validateJson: (json)->
    try
      object = @parseQueryStringForQuery json
    catch ex
      return [ ex.message, null ]
    return [ null, object ]

  _validateQueryString: ->
    try
      object = @parseQueryStringForQuery @queryString
    catch ex
      @queryInputErrorMessage = ex.message
      return null
    @queryInputErrorMessage = ''
    return object

  queryStringAltered: ->
    if @queryString.length isnt 0
      @_validateQueryString()

  convertToJsonButtonTapped: (e)->
    if @queryStringTypeSelectedIndex is 0
      if object = @_validateQueryString()
        string = JSON.stringify object, null, 2
        @queryStringTypeSelectedIndex = 1
        @queryString = string
      else
        @domHost.showToast "Please enter valid CSON first."

  prettifyButtonTapped: (e)->
    if @queryStringTypeSelectedIndex is 1
      if object = @_validateQueryString()
        string = JSON.stringify object, null, 2
        @queryString = string
    else
      @domHost.showToast "Unable to prettify CSON"

  _runQuery: (object, cbfn)->
    token = (new Date).getTime()
    @callQueryApi {
      "apiKey": @domHost.user.apiKey,
      "query": JSON.stringify object
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
      
      newDoc = @parseQueryStringForQuery (@get "docList.#{docIndex}.__nedbmgr__.value")
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
    object = @parseQueryStringForQuery text
    delete object['_id'] if '_id' of object
    delete object['__nedbmgr__'] if '__nedbmgr__' of object
    text = JSON.stringify object, null, 2
    return text

  _checkOpenedDatabasesAndSelectDefault: ->
    if not @domHost.serverDatabase.isOpen
      @domHost.showModalDialog "Please open a database before querying.", =>
        @domHost.navigateToPage '#/'

  navigatedIn: ->
    @_checkOpenedDatabasesAndSelectDefault()
    @_loadAndDisplayStoredQueryList()

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
