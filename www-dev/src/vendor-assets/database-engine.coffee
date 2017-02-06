
### =======================================
## Database Engine
## Originally created by Sayem Shafayet
## extended by ParticleIT
======================================= ###

deepCopy = (object)-> JSON.parse JSON.stringify object

class DatabaseEngine

  @EngineDataModelVersion: 1

  @IdentifierPrefix = 'database-engine-db-'

  @UniqueDocumentKey = '_id'

  constructor: (options = {})->

    {
      @name
      @storageEngine
      # @compressionEngine
      # @encryptionEngine
      @schemaEngine
      @serializationEngine
      @engineDataMigrationScripts
      config
    } = options

    unless (@name and typeof @name is 'string')
      throw new Error "Expected 'name' of database"

    unless @storageEngine
      throw new Error "Expected 'storageEngine'"

    unless @serializationEngine
      throw new Error "Expected 'serializationEngine'"

    @schemaEngine or= null

    @engineDataMigrationScripts or= {}

    config or= {}

    {
      commitDelay
    } = config

    commitDelay or= 0

    @config = {
      commitDelay
    }

    @databaseIdentifier = @constructor.IdentifierPrefix + @name

    @database = null

    @definition = {}

  _saveDatabase: ->

    @database.lastSavedDatetimeStamp = (new Date).getTime()

    @storageEngine.setItem @databaseIdentifier, (@serializationEngine.stringify @database)

  _createNewDatabase: ->

    @database = {}
    
    @database.engineDataModelVersion = @constructor.EngineDataModelVersion

    @database.createdDatetimeStamp = (new Date).getTime()

    @database.lastModifiedDatetimeStamp = (new Date).getTime()

    @database.collections = {}

    @_saveDatabase()

  _upgradeDataModel: ->

    throw new Error 'Feature Under Construction'

  _loadExistingDatabase: ->

    @database = @serializationEngine.parse @storageEngine.getItem @databaseIdentifier

    if @database.engineDataModelVersion isnt @constructor.EngineDataModelVersion

      @_upgradeDataModel()

    @_saveDatabase()

  removeExistingDatabase: ->

    @storageEngine.removeItem @databaseIdentifier

    @database = null

  initializeDatabase: (options = {})->

    { removeExisting } = options

    removeExisting or= false

    if @storageEngine.hasItem @databaseIdentifier

      if removeExisting

        @removeExistingDatabase()

        return @_createNewDatabase()

      else

        return @_loadExistingDatabase()

    else

      return @_createNewDatabase()

  defineCollection: (options)->

    {
      name
      schema
      validatorFn
    } = options

    schema or= null

    validatorFn or= null

    @definition[name] = {
      name
      schema
      validatorFn
    }

  _getDefinition: (collectionName)->

    unless collectionName of @definition
      throw new Error "Unknown collection '#{collectionName}'"

    return @definition[collectionName]

  _getCollection: (collectionName)->

    unless collectionName of @database.collections

      @database.collections[collectionName] = {
        docList: []
        serialSeed: 0
        meta: {}
      }

    return @database.collections[collectionName]

  _notifyDatabaseChange: (type, param1 = null, param2 = null, param3 = null)->

    ## TODO Factor in @options.commitDelay

    @_saveDatabase()

  getCollectionNameList: ->

    return Object.keys(@definition)

  insert: (collectionName, doc)->

    unless doc and typeof doc is 'object'
      throw new Error "doc must be a non-null 'object'"

    doc = deepCopy doc

    collectionDefinition = @_getDefinition collectionName

    if collectionDefinition.schema and @schemaEngine

      if (error = @schemaEngine.isDataValid schema, doc)
        throw error

    if collectionDefinition.validatorFn

      if (error = validatorFn doc)
        throw error

    collection = @_getCollection collectionName

    doc[@constructor.UniqueDocumentKey] = collection.serialSeed
    collection.serialSeed += 1

    collection.docList.push doc

    @_notifyDatabaseChange 'insert', collectionName, doc

    return doc[@constructor.UniqueDocumentKey]

  find: (collectionName, filterFn = null)->

    @_getDefinition collectionName

    collection = @_getCollection collectionName

    matchedDocList = []

    for doc, index in collection.docList

      if filterFn

        unless filterFn doc

          continue

      matchedDocList.push deepCopy doc

    return matchedDocList

  update: (collectionName, valueOfUniqueKey, newDoc)->

    @_getDefinition collectionName

    collection = @_getCollection collectionName

    oldDocIndex = null

    for doc, index in collection.docList

      if doc[@constructor.UniqueDocumentKey] is valueOfUniqueKey

        oldDocIndex = index

        break

    return false if oldDocIndex is null

    newDoc[@constructor.UniqueDocumentKey] = valueOfUniqueKey

    collection.docList.splice oldDocIndex, 1, deepCopy newDoc

    @_notifyDatabaseChange 'update', collectionName, newDoc

    return true

  remove: (collectionName, valueOfUniqueKey)->

    @_getDefinition collectionName

    collection = @_getCollection collectionName

    oldDocIndex = null

    for doc, index in collection.docList

      if doc[@constructor.UniqueDocumentKey] is valueOfUniqueKey

        oldDocIndex = index

        break

    return false if oldDocIndex is null

    collection.docList.splice oldDocIndex, 1

    @_notifyDatabaseChange 'remove', collectionName, valueOfUniqueKey

    return true

  upsert: (collectionName, newDoc, filterFn)->

    docList = @find collectionName, filterFn

    if docList.length is 0

      return @insert collectionName, newDoc

    else if docList.length is 1

      return @update collectionName, docList[0][@constructor.UniqueDocumentKey], newDoc

    else

      throw new Error "Cannot do 'upsert' on multiple rows"

  computeTotalSpaceTaken: ->

    return (@storageEngine.getItem @databaseIdentifier).length

window['database-engine'] = { DatabaseEngine: DatabaseEngine }

