Preload = require './preload/load'
Editor = require './editor'
Main = require './gui/main'


class Application
  init: ->
    React.render(Main(), document.getElementById('content'))
    Preload.start @loadComplete

  loadComplete: =>
    @editor = new Editor @

app = new Application()
app.init()
