

LIM = 100
doneCount = 0
for i in [0...LIM]
  object = {
    collection: 'post'
    userSerial: 0
    title: "post no. #{i+1}"
    content: "Dummy Data"
    serial: i
  }
  insert object, (err)->
    if err
      error err
    else
      doneCount += 1
      if doneCount is LIM-1
        done()
        