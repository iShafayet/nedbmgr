
Hapi = require('hapi')
Good = require('good')
Joi = require('joi')

internal = require './internal'
{ 
  handleError
  makeStandardReply 
} = require './utilities'

{ 
  openDatabaseFile
  runQuery
  updateSingleDoc
  removeSingleDoc
} = require './functions'

@createNedbmgrServer = (options)->

  server = new Hapi.Server
  server.connection { 
    host: options.apiServer.host
    port: options.apiServer.port
    routes:
      cors: true
  }

  server.route
    method: 'POST'
    path: '/api/1/login'
    config: 
      validate: 
        payload:
          emailOrPhone: Joi.string().min(3).max(30).required()
          password: Joi.string().min(3).max(30).required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { emailOrPhone, password } = request.payload
      internal.login emailOrPhone, password, (err, { apiKey, name })=>
        if err
          return reply handleError err
        else
          return reply makeStandardReply { apiKey, name }

  server.route
    method: 'POST'
    path: '/api/1/open-db'
    config: 
      validate: 
        payload:
          apiKey: Joi.string().required()
          path: Joi.string().required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { apiKey, path } = request.payload
      internal.getUserIdFromApiKey apiKey, (err, userId)=>
        if err
          return reply handleError err
        else
          openDatabaseFile path, (err)=>
            if err
              return reply handleError err
            else
              return reply makeStandardReply { opened: true }

  server.route
    method: 'POST'
    path: '/api/1/query'
    config: 
      validate: 
        payload:
          apiKey: Joi.string().required()
          query: Joi.object().required()
          skip: Joi.number().required()
          limit: Joi.number().required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { apiKey, query, skip, limit } = request.payload
      internal.getUserIdFromApiKey apiKey, (err, userId)=>
        if err
          return reply handleError err
        else
          runQuery query, skip, limit, (err, count, docList)=>
            if err
              return reply handleError err
            else
              return reply makeStandardReply { count, docList }

  server.route
    method: 'POST'
    path: '/api/1/update-doc'
    config: 
      validate: 
        payload:
          apiKey: Joi.string().required()
          doc: Joi.object().required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { apiKey, doc } = request.payload
      internal.getUserIdFromApiKey apiKey, (err, userId)=>
        if err
          return reply handleError err
        else
          updateSingleDoc doc, (err, wasUpdated)=>
            if err
              return reply handleError err
            else
              return reply makeStandardReply { updated: wasUpdated }

  server.route
    method: 'POST'
    path: '/api/1/remove-doc'
    config: 
      validate: 
        payload:
          apiKey: Joi.string().required()
          id: Joi.string().required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { apiKey, id } = request.payload
      internal.getUserIdFromApiKey apiKey, (err, userId)=>
        if err
          return reply handleError err
        else
          removeSingleDoc id, (err, wasDeleted)=>
            if err
              return reply handleError err
            else
              return reply makeStandardReply { deleted: wasDeleted }

  server.register {
    register: Good
    options: 
      reporters: 
        console: [
          {
            module: 'good-squeeze'
            name: 'Squeeze'
            args: [ {
              response: '*'
              log: '*'
            } ]
          }
          { module: 'good-console' }
          'stdout'
        ]
    }, (err) ->
      if err
        throw err

      server.start (err) ->
        if err
          throw err
        server.log 'info', 'Server running at: ' + server.info.uri
        return

