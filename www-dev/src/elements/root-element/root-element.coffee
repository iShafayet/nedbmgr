
Polymer {

  is: 'root-element'

  behaviors: [ 
    app.behaviors.commonComputes
    app.behaviors.apiCalling
    app.behaviors.dbUsing
    app.behaviors.debug
    app.behaviors.local['root-element'].dataTransformation
    app.behaviors.local['root-element'].dataLoader
    app.behaviors.local['root-element'].navigation
    app.behaviors.local['root-element'].commonDialogs
    app.behaviors.local['root-element'].pageReadyMechanism
    app.behaviors.local['root-element'].apiAndDownloadActions
  ]

  properties:

    page:
      type: Object
      observer: '_pageObjectChanged'

    viewName:
      type: String
      value: null

    user:
      type: Object
      value: null

    serverOptions:
      type: Object
      value: null

    connection:
      type: Object
      value: -> {
          isLive: false
          needsInput: false
          enteredServerHost: ''
        }

  mutexes: {}

  _initMutexes: ->
    @mutexes.readyToNavigate = new lib.util.Mutex 'RoutingDone', 'ConnectionEstablished'
    .finally @, @readyToNavigate

  created: ->
    @removeUserUnlessSessionIsPersistent()
    @_loadStaticData()
    @_initMutexes()

  ready: ->
    @_fillIronPagesFromPageList()
    @_applyUiTweaks()
    @_loadUser()
    @_createConnectionToServerAndFetchOptions()

  readyToNavigate: ->
    @mutexes.readyToNavigate.deprive 'RoutingDone'
    @viewName = @page.name

  _loadUser: ->
    @user = @getCurrentUser()

  # === Create initial connection and fetch options from server ===

  retryConnectionTapped: (e)->
    @set 'connection.needsInput', false
    meta = @getMeta()
    meta = { serial: 'only' } unless meta
    meta.serverHost = @connection.enteredServerHost
    @setMeta meta
    @_createConnectionToServerAndFetchOptions()    

  _createConnectionToServerAndFetchOptions: ->
    if (meta = @getMeta())

      { serverHost } = meta
      app.config.serverHost = serverHost

    @callConnectApi {}, (err, response)=>
      if err
        @set 'connection.isLive', false
        @set 'connection.needsInput', true
        @set 'connection.enteredServerHost', app.config.serverHost
      else if response.statusCode isnt 200
        @set 'connection.isLive', false
        @set 'connection.needsInput', true
        @set 'connection.enteredServerHost', app.config.serverHost
        @showModalDialog response.message
      else
        @set 'connection.isLive', true
        @set 'connection.needsInput', false
        @set 'connection.enteredServerHost', app.config.serverHost
        meta = { serial: 'only' } unless meta
        meta.serverHost = app.config.serverHost
        @setMeta meta
        { options } = response.data
        @serverOptions = options
        console.log '@serverOptions', @serverOptions
        @mutexes.readyToNavigate.satisfy 'ConnectionEstablished'

  # === Events manually delegated to current page ===

  saveButtonPressed: (e)->
    @$$('iron-pages').selectedItem.saveButtonPressed e

  printButtonPressed: (e)->
    @$$('iron-pages').selectedItem.printButtonPressed e

  arrowBackButtonPressed: (e)->
    @$$('iron-pages').selectedItem.arrowBackButtonPressed e

  showDashboardButtonPressed: (e)->
    @$$('iron-pages').selectedItem.showDashboardButtonPressed e

  # === Events ===

  refreshButtonPressed: (e)->
    @reloadPage()

  logoutPressed: (e)->
    @removeAllUserInfo()
    @navigateToPage '#/login'
    @$$('app-drawer').toggle()

  settingsButtonPressed: (e)->
    @navigateToPage '#/settings'

  loginButtonPressed: (e)->
    @navigateToPage '#/login'

  # === Page Management ===

  _fillIronPagesFromPageList: ->
    ironPages = Polymer.dom(@root).querySelector 'iron-pages'

    fullPageList = [].concat app.pages.pageList, app.pages.error404

    for page in fullPageList
      pageElement = document.createElement page.element
      pageElement.setAttribute 'name', page.name

      Polymer.dom(ironPages).appendChild pageElement

  _pageObjectChanged: (page) ->
    doAfterImport = -> null
    pagePath = @resolveUrl ('../' + page.element + '/' + page.element + '.html')
    @importHref pagePath, doAfterImport, doAfterImport, false

    @mutexes.readyToNavigate.satisfy 'RoutingDone'

  # === Misc ===

  $isDevMode: ->
    (window.location.hostname in [ "127.0.0.1", "localhost" ])

  _applyUiTweaks: ->
    @$$('app-drawer-layout').responsiveWidth = '14400px'

}
