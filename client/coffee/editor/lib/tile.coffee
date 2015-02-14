{tileWidth, tileHeight} = require './utils'

module.exports = class Tile extends createjs.Sprite
  constructor: (x, y, @tile, @tilesheet) ->
    super @tilesheet

    @gotoAndStop @tile
    @pos =
      x: x
      y: y

    @x = x * tileWidth
    @y = y * tileHeight

