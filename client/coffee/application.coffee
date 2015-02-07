Preload = require './preload/load'
Editor = require './editor'

class Application
  init: ->
    Preload.start @loadComplete

  loadComplete: =>
    @editor = new Editor @

app = new Application()
app.init()
