Editor = require './editor'
Main = require './gui/main'

Store = require './flux/stores'
Actions = require './flux/actions'

flux = new Fluxxor.Flux {Store: new Store()}, Actions
window.flux = flux

flux.on "dispatch", (type, payload) ->
  if window.debug_on
    console.log "[Dispatch]", type, payload

class Application
  init: ->
    React.render(Main(flux: flux), document.getElementById('content'))
    @editor = new Editor()

app = new Application()
app.init()
