
GENERIC_API_CALLING_DELAY = 500

app.behaviors.apiCalling = 

  callApi: (apiPath, data, cbfn)->
    apiActionId = @domHost.notifyApiAction  'start', apiPath
    lib.network.callNedbmgrPostApi apiPath, data, (err, response)=>
      if err
        console.log err, response
        alert "Error Happened."
      if response.statusCode isnt 200
        @domHost.notifyApiAction 'error', apiPath, apiActionId
      else
        @domHost.notifyApiAction 'done', apiPath, apiActionId
      cbfn err, response

  callLoginApi: (data, cbfn)->
    @callApi 'login', data, (err, response)=>
      cbfn err, response

  callOpenDbApi: (data, cbfn)->
    @callApi 'open-db', data, (err, response)=>
      cbfn err, response

  callQueryApi: (data, cbfn)->
    @callApi 'query', data, (err, response)=>
      cbfn err, response

  callUpdateDocApi: (data, cbfn)->
    @callApi 'update-doc', data, (err, response)=>
      cbfn err, response

  callRemoveDocApi: (data, cbfn)->
    @callApi 'remove-doc', data, (err, response)=>
      cbfn err, response

  callBulkUpdateApi: (data, cbfn)->
    @callApi 'bulk-update', data, (err, response)=>
      cbfn err, response

  callBulkDeleteApi: (data, cbfn)->
    @callApi 'bulk-delete', data, (err, response)=>
      cbfn err, response

