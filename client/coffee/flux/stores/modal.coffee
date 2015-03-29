_c = require '../constants'

module.exports = Fluxxor.createStore
  initialize: ->
    @open = false
    @type = null
    @props = {}

    @bindActions(
      _c.OPEN_MODAL, @openModal
      _c.CLOSE_MODAL, @closeModal
    )

  openModal: ({ type, props }) ->
    @type = type
    @props = props
    @open = true

    @emit 'change'

  closeModal: ->
    @open = false
    @type = null
    @props = {}

    @emit 'change'

  getState: ->
    open: @open
    type: @type
    props: @props
