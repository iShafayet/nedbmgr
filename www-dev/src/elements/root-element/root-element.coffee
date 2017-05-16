
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
  ]

  properties:

    page:
      type: Object
      observer: '_mainViewPageChanged'

    downloadActions:
      type: Object
      value: 
        count: 0
        seed: 0
        list: []

    apiActions:
      type: Object
      value: 
        count: 0
        seed: 0
        list: []

    user:
      type: Object
      value: null

    openedDatabaseList:
      type: Array
      value: -> []

    activeDatabaseSelectedIndex: 
      type: Number
      value: 0

    currentNavigationCandidate:
      type: String
      value: ''

    readyPageNodeNameList:
      type: Array
      value: []

    genericModalDialogContents: 
      type: String
      value: 'Content goes here...'

    genericToastContents: 
      type: String
      value: 'Content goes here...'

    clockDatetimeStamp:
      type: Number
      notify: true

    hasLoadingStarted:
      type: Boolean
      value: true

    hasLoadingFinished:
      type: Boolean
      value: false

  observers: [ 
    '_routerHrefChanged(routeData.page)'
  ]

  notifyApiAction: (action, moreData...)->
    if action is 'start'
      @apiActions.count += 1
      @notifyPath 'apiActions.count'
      [ path ] = moreData
      obj = 
        id: @apiActions.seed++
        path: moreData[path]
        time: lib.datetime.now()
        action: 'start'
      @apiActions.list.push obj
      return obj.id
    else if action is 'done'
      @apiActions.count -= 1 unless @apiActions.count is 0
      @notifyPath 'apiActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @apiActions.seed++
        path: path
        refId: refId
        action: 'done'
      @apiActions.list.push obj
      return obj.id
    else if action is 'error'
      @apiActions.count -= 1 unless @apiActions.count is 0
      @notifyPath 'apiActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @apiActions.seed++
        path: path
        refId: refId
        action: 'error'
      @apiActions.list.push obj
      return obj.id

  notifyDownloadAction: (action, moreData...)->
    if action is 'start'
      @downloadActions.count += 1
      @notifyPath 'downloadActions.count'
      [ path ] = moreData
      obj = 
        id: @downloadActions.seed++
        path: moreData[path]
        time: lib.datetime.now()
        action: 'start'
      @downloadActions.list.push obj
      return obj.id
    else if action is 'done'
      @downloadActions.count -= 1 unless @downloadActions.count is 0
      @notifyPath 'downloadActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @downloadActions.seed++
        path: path
        refId: refId
        action: 'done'
      @downloadActions.list.push obj
      return obj.id
    else if action is 'error'
      @downloadActions.count -= 1 unless @downloadActions.count is 0
      @notifyPath 'downloadActions.count'
      [ path, refId ] = moreData
      obj = 
        id: @downloadActions.seed++
        path: path
        refId: refId
        action: 'error'
      @downloadActions.list.push obj
      return obj.id

  $isDevMode: ->
    (window.location.hostname in [ "127.0.0.1", "localhost" ])

  _routerHrefChanged: (href) ->
    # @debug '_routerHrefChanged', href
    href = '/' unless href
    wasPageFound = false
    possiblePage = null

    for page in app.pages.pageList
      if href in page.hrefList
        possiblePage = page
        wasPageFound = true
        break

    if @isUserLoggedIn()
      @user = @getCurrentUser()
    else
      @user = null
    
    @openedDatabaseFn = =>
      if wasPageFound
        if possiblePage.requireAuthentication
          if @isUserLoggedIn()
            @page = possiblePage
          else
            @navigateToPage '#/login'
        else
          @page = possiblePage
      else
        @page = app.pages.error404

    if @user and @user.apiKey
      @_callOpenedDatabaseFn()
    else
      @openedDatabaseFn()

  _preloadOtherPages: ->
    # @debug '_preloadOtherPages'
    fullPageList = [].concat app.pages.pageList, [ app.pages.error404 ]

    for page in fullPageList
      do (page)=>
        unless page.name is @page.name
          pagePath = @resolveUrl ('../' + page.element + '/' + page.element + '.html')
          id = @notifyDownloadAction 'start', pagePath
          successCbfn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'done', pagePath, id
          failureCbfn = lib.network.ensureBaseNetworkDelay => @notifyDownloadAction 'error', pagePath, id
          @importHref pagePath, successCbfn, failureCbfn, true

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

  _fillIronPagesFromPageList: ->
    ironPages = Polymer.dom(@root).querySelector 'iron-pages'

    fullPageList = [].concat app.pages.pageList, app.pages.error404

    for page in fullPageList
      pageElement = document.createElement page.element
      pageElement.setAttribute 'name', page.name

      Polymer.dom(ironPages).appendChild pageElement

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

  # === NOTE - Common Dialog Boxes ===

  showModalDialog: (content, doneCallback = null)->
    @genericModalDialogContents = content
    @$$('#generic-modal-dialog').toggle()
    @genericModalDialogDoneCallback = doneCallback

  genericModalDialogClosed: (e)->
    if @genericModalDialogDoneCallback
      @genericModalDialogDoneCallback()
      @genericModalDialogDoneCallback = null

  showModalPrompt: (content, doneCallback)->
    @genericModalPromptContents = content
    @$$('#generic-modal-prompt').toggle()
    @genericModalPromptDoneCallback = doneCallback

  genericModalPromptClosed: (e)->
    if e.detail.confirmed
      @genericModalPromptDoneCallback true
    else
      @genericModalPromptDoneCallback false
    @genericModalPromptDoneCallback = null

  showToast: (content)->
    @genericToastContents = content
    @$$('#toast1').open()

  genericToastTapped: (e)->
    @$$('#toast1').close()

  # === NOTE - These events are manually delegated to pages ===

  saveButtonPressed: (e)->
    @$$('iron-pages').selectedItem.saveButtonPressed e

  printButtonPressed: (e)->
    @$$('iron-pages').selectedItem.printButtonPressed e

  arrowBackButtonPressed: (e)->
    @$$('iron-pages').selectedItem.arrowBackButtonPressed e

  showDashboardButtonPressed: (e)->
    @$$('iron-pages').selectedItem.showDashboardButtonPressed e

  # == NOTE - ...

  settingsButtonPressed: (e)->
    @navigateToPage '#/settings'

  loginButtonPressed: (e)->
    @navigateToPage '#/login'

  # === NOTE - navigation code ===

  getPageParams: ->
    hash = window.location.hash
    hash = hash.replace '#/', ''
    partArray = hash.split '/'
    partArray.shift()
    params = {}
    for part in partArray
      if part.indexOf(':') is -1
        @showModalDialog 'Malformatted Url Given'
        break
      [ left, right ] = part.split ':'
      params[left] = right
    return params

  navigateToPage: (path)->
    window.location = path

  navigateToPreviousPage: ->
    window.history.back()

  modifyCurrentPagePath: (newPath)->
    window.history.replaceState {}, newPath, newPath

  reloadPage: ->
    window.location.reload()

  # === NOTE - The code below generates the pseudo-lifetime-callback 'navigatedIn' ===

  ironPagesSelectedEvent: (e)->
    return unless Polymer.dom(e).rootTarget.nodeName is 'IRON-PAGES'
    nodeName = e.detail.item.nodeName
    for readyPageNodeName in @readyPageNodeNameList
      if readyPageNodeName is nodeName
        e.detail.item.navigatedIn() if e.detail.item.navigatedIn
        return
    @currentNavigationCandidate = nodeName

  pageReady: (pageElement)->
    @readyPageNodeNameList.push pageElement.nodeName
    if @currentNavigationCandidate is pageElement.nodeName
      @currentNavigationCandidate = ''
      pageElement.navigatedIn() if pageElement.navigatedIn

  ironPagesDeselectedEvent: (e)->
    return unless Polymer.dom(e).rootTarget.nodeName is 'IRON-PAGES'
    nodeName = e.detail.item.nodeName
    for readyPageNodeName in @readyPageNodeNameList
      if readyPageNodeName is nodeName
        e.detail.item.navigatedOut() if e.detail.item.navigatedOut
        return

  ## APP-WIDE-CLOCK =====================================================================

  _updateClock: ->
    @clockDatetimeStamp = lib.datetime.now()

  _clockUpdateStep: ->
    last = @clockDatetimeStamp or lib.datetime.now()
    @clockDatetimeStamp = lib.datetime.now()
    diff = @clockDatetimeStamp - last
    if diff > 900
      @_updateClock()
    else
      lib.util.delay (950 - diff), => @_clockUpdateStep()

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
