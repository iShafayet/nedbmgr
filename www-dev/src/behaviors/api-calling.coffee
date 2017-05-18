
app.behaviors.apiCalling = 

  bindToSelfOrHost: (name)->
    if name of @
      @[name].bind @
    else if @domHost and (name of @domHost)
      @domHost[name].bind @domHost
    else
      throw new Error "Property to be bound was not found"

  @appendDatabaseUid: (data)->
    if 'serverDatabase' of @
      data.uid = @serverDatabase.uid
    else if 'serverDatabase' of @domHost
      data.uid = @domHost.serverDatabase.uid
    else
      throw new Error "serverDatabase does not exist"

  callApi: (apiPath, data, autoHandleErrors, autoHandleNon200, cbfn)->
    fn = @bindToSelfOrHost 'notifyApiAction'
    apiActionId = fn 'start', apiPath
    lib.network.callNedbmgrPostApi apiPath, data, (err, response)=>
      lib.util.delay app.config.apiCallingMinimumDelay, =>
        if err
          console.log 'Network Error', err, response
          if autoHandleErrors
            (@bindToSelfOrHost 'showModalDialog')('Unexpected network error occurred.')
          fn 'error', apiPath, apiActionId
        else if response.statusCode isnt 200
          fn 'error', apiPath, apiActionId
        else
          fn 'done', apiPath, apiActionId
        cbfn err, response

  callConnectApi: (data, cbfn)->
    @callApi 'connect', data, false, false, (err, response)=>
      cbfn err, response

  callLoginApi: (data, cbfn)->
    @callApi 'login', data, true, false, (err, response)=>
      cbfn err, response

  callOpenDbApi: (data, cbfn)->
    @callApi 'open-db', data, true, false, (err, response)=>
      cbfn err, response

  callQueryApi: (data, cbfn)->
    @appendDatabaseUid data
    @callApi 'query', data, true, false, (err, response)=>
      cbfn err, response

  callUpdateDocApi: (data, cbfn)->
    @appendDatabaseUid data
    @callApi 'update-doc', data, true, false, (err, response)=>
      cbfn err, response

  callRemoveDocApi: (data, cbfn)->
    @appendDatabaseUid data
    @callApi 'remove-doc', data, true, false, (err, response)=>
      cbfn err, response

  callBulkUpdateApi: (data, cbfn)->
    @appendDatabaseUid data
    @callApi 'bulk-update', data, true, false, (err, response)=>
      cbfn err, response

  callBulkDeleteApi: (data, cbfn)->
    @appendDatabaseUid data
    @callApi 'bulk-delete', data, true, false, (err, response)=>
      cbfn err, response

  callGetOpenedDatabaseListApi: (data, cbfn)->
    @appendDatabaseUid data
    @callApi 'get-opened-db-list', data, true, false, (err, response)=>
      cbfn err, response

  callGetOpenedDatabaseListApi: (data, cbfn)->
    @appendDatabaseUid data
    @callApi 'get-opened-db-list', data, true, false, (err, response)=>
      cbfn err, response

  callFetchStoredQueryListApi: (data, cbfn)->
    @callApi 'fetch-stored-query-list', data, true, false, (err, response)=>
      cbfn err, response

  callSaveQueryInQueryStoreApi: (data, cbfn)->
    @callApi 'save-query-in-query-store', data, true, false, (err, response)=>
      cbfn err, response

  callDeleteQueryFromQueryStoreApi: (data, cbfn)->
    @callApi 'delete-query-from-query-store', data, true, false, (err, response)=>
      cbfn err, response

  callRunCodeApi: (data, cbfn)->
    @callApi 'run-code', data, true, false, (err, response)=>
      cbfn err, response