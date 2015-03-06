_c = require '../constants'

module.exports = Fluxxor.createStore
  initialize: ->
    @quickSelectIndicies = (null for i in [0..9])

    @bindActions(
      _c.ADD_QUICK_SELECT, @addQuickSelect
    )

  addQuickSelect: ({pos, index}) ->
    return unless 0 <= pos <= 9
    @quickSelectIndicies[pos] = index
    @emit 'change'

  getState: ->
    quickSelectIndicies: @quickSelectIndicies
