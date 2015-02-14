Preload = require './preload/load'
Editor = require './editor'
Main = require './gui/main'
em = require  './event_manager'

class Application
  init: ->
    $(window).keydown (e) -> em.call 'keydown', [e]
    $(window).keyup (e) -> em.call 'keyup', [e]

    React.render(Main(), document.getElementById('content'))
    Preload.start @loadComplete

  loadComplete: =>
    @editor = new Editor @
    em.call "add-layer", ["layer 1"]

app = new Application()
app.init()
