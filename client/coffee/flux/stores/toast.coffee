_c = require '../constants'

module.exports = Fluxxor.createStore
  initialize: ->
    type: 'info'
    message: null

    @bindActions(
      _c.ADD_TOAST, @addToast
    )

  addToast: ({type, message}) ->
    @type = type || 'info'
    @message = message
    @emit 'change'

  getState: ->
    type: @type
    message: @message
