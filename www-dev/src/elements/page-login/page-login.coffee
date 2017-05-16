
Polymer {
  is: 'page-login'

  behaviors: [
    app.behaviors.dbUsing
    app.behaviors.apiCalling
    app.behaviors.translating
    app.behaviors.pageLike
  ]

  properties:

    loginFormData: 
      type: Object
      notify: true
      value: do ->
        if app.mode is 'production'
          emailOrPhone: ''
          password: ''
        else
          emailOrPhone: 'john@example.com'
          password: 'Password1'
        
    shouldRememberUser: 
      type: Boolean
      notify: true
      value: true

  showDashboardButtonPressed: (e)->
    @domHost.navigateToPage '#/'

  forgotPasswordPressed: (e)->
    contact = @domHost.serverOptions.user.recoveryContact
    @domHost.showModalDialog "Please contact #{contact} to request an account recovery."

  loginButtonPressed: (e)->
    @callLoginApi @loginFormData, (err, response)=>
      if response.statusCode isnt 200
        @domHost.showModalDialog response.message
      else
        user = response.data
        @loginDbAction user, @shouldRememberUser 
        @domHost._loadUser()
        @domHost.navigateToPage '#/'        
        # @domHost.updateOpenedDatabaseList()


}
