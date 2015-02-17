class Stamp
  constructor: ->
    @index = 0

    @multiple = false

    @indicies = []

  setSingle: (index) ->
    @multiple = false
    @index = index

  setMultiple: (indicies) ->
    @multiple = true
    @indicies = indicies

module.exports = new Stamp()

