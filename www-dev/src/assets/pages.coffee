
###
  app.pages
###

app.pages = {}

app.pages.pageList = [
 {
    name: 'dashboard'
    element: 'page-dashboard'
    windowTitlePostfix: 'NeDBmgr'
    headerTitle: 'NeDBmgr'
    preload: true
    hrefList: [ '/', 'dashboard' ]
    requireAuthentication : false
    headerType: 'normal'
    leftMenuEnabled: true
  }
  {
    name: 'login'
    element: 'page-login'
    windowTitlePostfix: 'NeDBmgr'
    headerTitle: 'NeDBmgr'
    preload: true
    hrefList: [ 'login' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: false
    showDashboardButton: true
    hideLoginButton: true
  }
  {
    name: 'settings'
    element: 'page-settings'
    windowTitlePostfix: 'Settings'
    headerTitle: 'Settings'
    preload: true
    hrefList: [ 'settings' ]
    requireAuthentication : true
    headerType: 'modal'
    leftMenuEnabled: true
    showSaveButton: true
    showBackButton: true
    hideLoginButton: true
  }
  {
    name: 'update'
    element: 'page-update'
    windowTitlePostfix: 'Bulk Update'
    headerTitle: 'Bulk Update'
    preload: true
    hrefList: [ 'update' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showBackButton: true
    hideLoginButton: true
  }
  {
    name: 'search'
    element: 'page-search'
    windowTitlePostfix: 'Search and Edit'
    headerTitle: 'Search and Edit'
    preload: true
    hrefList: [ 'search' ]
    requireAuthentication : true
    headerType: 'normal'
    leftMenuEnabled: true
    showBackButton: true
    hideLoginButton: true
  }
  {
    name: 'dev-tools'
    element: 'dev-tools'
    windowTitlePostfix: 'Dev Tools'
    headerTitle: 'Dev Tools'
    preload: true
    hrefList: [ 'dev-tools' ]
    requireAuthentication : false
    headerType: 'modal'
    leftMenuEnabled: true
    leftMenuEnabled: true
    showSaveButton: true
    showBackButton: true
    hideLoginButton: true
  }
]

app.pages.error404 = {
  name: '404'
  element: 'page-error-404'
  windowTitlePostfix: 'Not Found'
  headerTitle: '404 Not Found'
  preload: true
  href: [ '/404' ]
  requireAuthentication : false
  headerType: 'normal'
  leftMenuEnabled: true
}