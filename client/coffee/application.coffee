Editor = require './editor'
Main = require './gui/main'
em = require  './event_manager'

Store = require './flux/stores'
Actions = require './flux/actions'

flux = new Fluxxor.Flux {Store: new Store()}, Actions
window.flux = flux

flux.on "dispatch", (type, payload) ->
  em.call type, [payload]
  console.log "[Dispatch]", type, payload

class Application
  init: ->
    $(window).keydown (e) -> em.call 'keydown', [e]
    $(window).keyup (e) -> em.call 'keyup', [e]

    React.render(Main(flux: flux), document.getElementById('content'))

    @editor = new Editor()

app = new Application()
app.init()
