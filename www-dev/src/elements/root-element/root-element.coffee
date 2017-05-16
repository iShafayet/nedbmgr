
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
      observer: '_pageObjectChanged'

    viewName:
      type: String
      value: null

    user:
      type: Object
      value: null

  created: ->
    @removeUserUnlessSessionIsPersistent()
    @_loadStaticData()

  ready: ->
    @_fillIronPagesFromPageList()
    @_applyUiTweaks()
    @_loadUser()

  _loadUser: ->
    @user = @getCurrentUser()

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

    @viewName = page.name

  # === Misc ===

  $isDevMode: ->
    (window.location.hostname in [ "127.0.0.1", "localhost" ])

  _applyUiTweaks: ->
    @$$('app-drawer-layout').responsiveWidth = '14400px'


}
