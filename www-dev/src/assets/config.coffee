
window.app = 

  mode: 'development' # can be - 'production' or 'development'

  config:

    clientIdentifier: 'nedbmgr'

    clientVersion: '0.0.8'

    clientPlatform: 'web' # can be - 'web', 'android', 'ios', 'windows', 'osx', 'ubuntu'

    masterApiVersion: '1'

    variableConfigs:

      'development':

        serverHost: 'http://localhost:8501'

      'production':

        serverHost: 'https://TOBEDECIDED:8501'

  options:

    baseNetworkDelay: 10

app.config.serverHost = app.config.variableConfigs[app.mode].serverHost


