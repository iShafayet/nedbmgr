

app.behaviors.local['root-element'] = {} unless app.behaviors.local['root-element']
app.behaviors.local['root-element'].timeKeeper = [
  {

    properties:

      clockDatetimeStamp:
        type: Number
        notify: true

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


  }

]