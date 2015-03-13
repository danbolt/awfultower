
{tileWidth, tileHeight} = require '../utils'

module.exports = class Peer
  constructor: (@uuid, @game) ->
    @highlight = @game.add.graphics()
    @preview = @game.add.group()

    @highlight.lineStyle 1, 0x00ff00, 1
    @highlight.drawRect 0, 0, tileWidth, tileHeight
    @preview.add @highlight

  update: (data) ->
    @preview.x = data.x * tileWidth
    @preview.y = data.y * tileHeight

