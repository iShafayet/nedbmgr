
__isPreloadCalled = false

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

    connection:
      type: Object
      value: -> {
          isLive: false
          needsInput: false
          enteredServerHost: ''
        }

  mutexes: 

    readyToNavigate: 
      descriptor: null
      fn: ->
        c = new lib.util.Collector 2
        c.finally =>
          c.count = 0
          c.collection = {}
          @readyToNavigate()

  _initMutexes: ->
    mutex.descriptor = mutex.fn.call @ for _, mutex of @mutexes

  _satisfyMutex: (name)->
    console.log name
    @mutexes[name].descriptor.collect 'a', null

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
    console.log 'YAY', @page
    @viewName = @page.name

  _loadUser: ->
    @user = @getCurrentUser()

  # === Create initial connection and fetch options from server ===

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
        meta = {} unless meta
        meta.serverHost = app.config.serverHost
        @setMeta meta
        { options } = response.data
        @_satisfyMutex 'readyToNavigate'


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

    @_satisfyMutex 'readyToNavigate'
    

  # === Misc ===

  $isDevMode: ->
    (window.location.hostname in [ "127.0.0.1", "localhost" ])

  _applyUiTweaks: ->
    @$$('app-drawer-layout').responsiveWidth = '14400px'


}
