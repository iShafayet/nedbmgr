
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
    app.behaviors.local['root-element'].apiAndDownloadActions
    app.behaviors.local['root-element'].commonDialogs
    app.behaviors.local['root-element'].pageReadyMechanism
  ]

  properties:

    page:
      type: Object
      observer: '_mainViewPageChanged'

    user:
      type: Object
      value: null

    openedDatabaseList:
      type: Array
      value: -> []

    activeDatabaseSelectedIndex: 
      type: Number
      value: 0



    hasLoadingStarted:
      type: Boolean
      value: true

    hasLoadingFinished:
      type: Boolean
      value: false

  observers: [ 
    '_routerHrefChanged(routeData.page)'
  ]

  $isDevMode: ->
    (window.location.hostname in [ "127.0.0.1", "localhost" ])

  _mainViewPageChanged: (page) ->
    # @debug '_mainViewPageChanged', page.name

    ## call preload only if not already preloaded
    callPreloaderAfterCheckingFn = =>
      return if __isPreloadCalled
      __isPreloadCalled = true
      ## FIXME - This feature does not work
      # @_preloadOtherPages() 

    ## load page import on demand.
    pagePath = @resolveUrl ('../' + page.element + '/' + page.element + '.html')
    @importHref pagePath, callPreloaderAfterCheckingFn, callPreloaderAfterCheckingFn, false



  created: ->
    @removeUserUnlessSessionIsPersistent()
    @_loadStaticData()

  ready: ->
    @_fillIronPagesFromPageList()
    ## UI Tweaks
    @$$('app-drawer-layout').responsiveWidth = '14400px'
    @updateOpenedDatabaseList()

  refreshButtonPressed: (e)->
    @reloadPage()

  logoutPressed: (e)->
    @removeAllUserInfo()
    @navigateToPage '#/login'
    @$$('app-drawer').toggle()

  # === NOTE: These events are manually delegated to pages ===

  saveButtonPressed: (e)->
    @$$('iron-pages').selectedItem.saveButtonPressed e

  printButtonPressed: (e)->
    @$$('iron-pages').selectedItem.printButtonPressed e

  arrowBackButtonPressed: (e)->
    @$$('iron-pages').selectedItem.arrowBackButtonPressed e

  showDashboardButtonPressed: (e)->
    @$$('iron-pages').selectedItem.showDashboardButtonPressed e

  # == NOTE ===

  settingsButtonPressed: (e)->
    @navigateToPage '#/settings'

  loginButtonPressed: (e)->
    @navigateToPage '#/login'


  ## APP-WIDE-CLOCK =====================================================================


  _callOpenedDatabaseFn: ->
    if @hasLoadingStarted
      if @hasLoadingFinished
        @openedDatabaseFn() if @openedDatabaseFn()
      else
        'pass'
    else
      @openedDatabaseFn() if @openedDatabaseFn()

  updateOpenedDatabaseList: ->
    if @user and @user.apiKey
      @hasLoadingStarted = true
      @hasLoadingFinished = false
      @callGetOpenedDatabaseListApi {
        "apiKey": @user.apiKey
      }, (err, response)=>
        if response.statusCode isnt 200
          @showModalDialog response.message
        else
          { openedDatabaseList } = response.data
          @openedDatabaseList = []
          @openedDatabaseList = openedDatabaseList
        @hasLoadingStarted = true
        @hasLoadingFinished = true
        @_callOpenedDatabaseFn()

  $isTruthy: (value)-> return value

  noDatabaseOpenedTapped: (e)->
    @navigateToPage '#/'

}
