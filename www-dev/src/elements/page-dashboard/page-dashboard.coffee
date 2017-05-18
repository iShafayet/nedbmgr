
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
      value: './test/manual/mydatabase.db'

  accessDbTapped: (e)->
    @domHost.$$('app-drawer').toggle()

  logInTapped: ->
    @domHost.navigateToPage '#/login'

  navigatedIn: ->
    @refreshKey = @refreshKey + 1
    @serverOptions = @domHost.serverOptions

  openPredefinedDbTapped: (e)->
    { path } = e.model.entry
    @domHost.openDatabase path, (err)=>
      @refreshKey = @refreshKey + 1

  openDbTapped: (e)->
    @domHost.openDatabase @enteredDatabasePath, (err)=>
      @refreshKey = @refreshKey + 1

}
