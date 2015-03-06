_c = require '../constants'

module.exports = Fluxxor.createStore
  initialize: ->
    @erase = false
    @grid = true

    @bindActions(
      _c.TOGGLE_ERASE, @toggleErase
      _c.TOGGLE_GRID, @toggleGrid
    )

  toggleGrid: (grid, type) ->
    g = if grid? then grid else not @grid
    @grid = g
    @emit 'change', type, g

  toggleErase: (erase, type) ->
    e = if erase? then erase else not @erase
    @erase = e
    @emit 'change', type, e

  getState: ->
    erase: @erase
    grid: @grid
