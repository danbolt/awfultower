Editor = require './editor'
Main = require './gui/main'
em = require  './event_manager'

class Application
  init: ->
    $(window).keydown (e) -> em.call 'keydown', [e]
    $(window).keyup (e) -> em.call 'keyup', [e]

    React.render(Main(), document.getElementById('content'))

    @editor = new Editor()

app = new Application()
app.init()
