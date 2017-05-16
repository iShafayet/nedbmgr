
app.db = new lib.DatabaseEngine {
  name: 'nedbmgr-db'
  storageEngine: lib.localStorage
  serializationEngine: lib.json
  config:
    commitDelay: 0
}

app.db.initializeDatabase { removeExisting: false }

app.db.defineCollection {
  name: 'user'
}

app.db.defineCollection {
  name: 'opened-database-meta'
}

app.db.defineCollection {
  name: 'settings'
}

app.db.defineCollection {
  name: '--persistent-session'
}

app.db.defineCollection {
  name: '--meta'
}

