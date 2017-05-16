
Polymer {

  is: 'page-dashboard'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.apiCalling
  ]

  properties:
    currentFetchRequestTime:
      type: Number
    refreshKey:
      type: Number
      value: 0
    dbPath:
      type: String
      value: './test1.db'

  logInTapped: ->
    @domHost.navigateToPage '#/login'

  navigatedIn: ->
    @refreshKey = @refreshKey + 1

  openDbTapped: (e)->
    @callOpenDbApi {
      "apiKey": @domHost.user.apiKey,
      "path": @dbPath
    }, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        if response.data.opened
          @domHost.showModalDialog "Database Opened"
          @domHost.updateOpenedDatabaseList()



}
