_ = require 'underscore'

module.exports = class Stamp
  constructor: (@delegate) ->

    @delegate.socket.on 'stamp_move',
      _.bind(@stampMove, @delegate)

  stampMove: (data) ->
    @broadcast 'stamp_move',
      uuid: @username
      x: data.x
      y: data.y



