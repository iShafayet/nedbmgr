
app.db = new lib.DatabaseEngine {
  name: 'nedbmgr-db'
  storageEngine: lib.localStorage
  serializationEngine: lib.json
  config:
    commitDelay: 0
}

app.db.initializeDatabase { removeExisting: false }

###
  user
    id
    apiKey
    name
    email
    phoneNumber
    address
      line
      district
      postalCode
    type ENUM [ 'ordinary', 'writer' ]
###
app.db.defineCollection {
  name: 'user'
}

app.db.defineCollection {
  name: 'opened-database-meta'
}

app.db.defineCollection {
  name: 'settings'
}


###
  --persistent-session
    shouldRememberUser Boolean
###
app.db.defineCollection {
  name: '--persistent-session'
}
