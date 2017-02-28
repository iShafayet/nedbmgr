
Hapi = require('hapi')
Good = require('good')
Joi = require('joi')

{ 
  normalizeOptions 
} = require './fn-options'

{ 
  userLogin
  getUserIdFromApiKey 
} = require './fn-user'

{
  handleError
  makeStandardReply 
} = require './fn-api'

{ 
  bulkDelete
  bulkUpdate
  useExternalDatabase
  openDatabaseFile
  runQuery
  updateSingleDoc
  removeSingleDoc
  getOpenedDatabaseList
} = require './fn-db'

@createNedbmgrServer = (options, nedbDatabaseObject, externCbfn)->

  options = normalizeOptions options

  if nedbDatabaseObject
    useExternalDatabase nedbDatabaseObject

  server = new Hapi.Server
  hapiServerOptions = { 
    port: options.apiServer.port
    routes:
      cors: true
  }
  if options.apiServer.host
    hapiServerOptions.host = options.apiServer.host
  server.connection hapiServerOptions

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
      userLogin emailOrPhone, password, (err, { apiKey, name })=>
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
      getUserIdFromApiKey apiKey, (err, userId)=>
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
    path: '/api/1/get-opened-db-list'
    config: 
      validate: 
        payload:
          apiKey: Joi.string().required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { apiKey, path } = request.payload
      getUserIdFromApiKey apiKey, (err, userId)=>
        if err
          return reply handleError err
        else
          openedDatabaseList = getOpenedDatabaseList()
          return reply makeStandardReply { openedDatabaseList }
          
          

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
      getUserIdFromApiKey apiKey, (err, userId)=>
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
    path: '/api/1/bulk-update'
    config: 
      validate: 
        payload:
          apiKey: Joi.string().required()
          query: Joi.object().required()
          updateCommand: Joi.object().required()
          shouldReturnUpdatedDocList: Joi.boolean().required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { apiKey, query, updateCommand, shouldReturnUpdatedDocList } = request.payload
      getUserIdFromApiKey apiKey, (err, userId)=>
        if err
          return reply handleError err
        else
          bulkUpdate query, updateCommand, (err, count)=>
            if err
              return reply handleError err
            else
              if shouldReturnUpdatedDocList
                runQuery query, 0, 9999, (err, _, docList)=>
                  return reply makeStandardReply { count, docList }
              else
                return reply makeStandardReply { count }


  server.route
    method: 'POST'
    path: '/api/1/bulk-delete'
    config: 
      validate: 
        payload:
          apiKey: Joi.string().required()
          query: Joi.object().required()
          '__meta': Joi.object()
    handler: (request, reply) ->
      { apiKey, query, } = request.payload
      getUserIdFromApiKey apiKey, (err, userId)=>
        if err
          return reply handleError err
        else
          bulkDelete query, (err, count)=>
            if err
              return reply handleError err
            else
              return reply makeStandardReply { count }

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
      getUserIdFromApiKey apiKey, (err, userId)=>
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
      getUserIdFromApiKey apiKey, (err, userId)=>
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

