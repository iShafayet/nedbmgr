
Polymer {

  is: 'page-run-code'

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
        """
        queryObject = {
          collection:"user-info",
          "emailAddressList.emailAddress": ""
        };
        query(queryObject, function(err, docList){
          if(err) {
            error(err);
          } else {
            collect(docList);
          }
          done();
        });
        """
      observer: 'queryStringAltered'
    queryInputErrorMessage:
      type: String
      value: ''
    resultMessage:
      type: String
      value: 'Results will appear here.'

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

  _validateQueryString: ->
    @queryInputErrorMessage = ''
    return @queryString

  queryStringAltered: ->
    if @queryString.length isnt 0
      @_validateQueryString()

  ## NOTE: Do not remove. 
  # prettifyButtonTapped: (e)->
  #   if object = @_validateQueryString()
  #     string = JSON.stringify object, null, 2
  #     @queryString = string

  _runQuery: (code, cbfn)->
    @lastAction = 'query'
    token = (new Date).getTime()
    @callRunCodeApi {
      "apiKey": @domHost.user.apiKey,
      "code": code
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        console.log response
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
      msg += "showing #{@docList.length} items"
    @resultMessage = msg

  runCodeButtonTapped: (e)->
    code = @_validateQueryString()
    unless code
      @domHost.showModalDialog "Your code has errors."
      return
    @_runQuery code, (timeTaken, {docList, logOutput, errorOutput})=>
      @lastQueryTimeTaken = timeTaken
      @totalCount = docList.length
      @docList = docList
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
    if @domHost.openedDatabaseList.length is 0
      @domHost.showModalDialog "Please open a database before querying.", =>
        @domHost.navigateToPage '#/'
    else 
      if @domHost.openedDatabaseList.length > 1
        @domHost.showModalDialog "Please note that opening multiple database are not yet supported. The last opened database will be automatically selected."

  navigatedIn: ->
    @_checkOpenedDatabasesAndSelectDefault()



}
