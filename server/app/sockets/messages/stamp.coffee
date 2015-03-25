_ = require 'underscore'

module.exports = class Stamp
  constructor: (@delegate) ->

    @delegate.socket.on 'stamp_move', @stampMove

  stampMove: (data) =>
    @delegate.broadcast 'stamp_move',
      uuid: @delegate.username
      x: data.x
      y: data.y



