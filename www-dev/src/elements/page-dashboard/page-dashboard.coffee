
Polymer {

  is: 'page-dashboard'

  behaviors: [ 
    app.behaviors.translating
    app.behaviors.pageLike
    app.behaviors.dbUsing
    app.behaviors.apiCalling
  ]

  properties:
    serverOptions:
      type: Object
      value: -> null
    refreshKey:
      type: Number
      value: 0
    enteredDatabasePath:
      type: String
      value: './mydatabase.db'

  logInTapped: ->
    @domHost.navigateToPage '#/login'

  navigatedIn: ->
    @refreshKey = @refreshKey + 1
    @serverOptions = @domHost.serverOptions

  openDbTapped: (e)->
    alert 'AA'
    return
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
