LevelData = require './level_data'

module.exports = class Tile extends createjs.Sprite
  constructor: (x, y, @tile, @tilesheet) ->
    super @tilesheet

    @tileWidth = LevelData.tileWidth
    @tileHeight = LevelData.tileHeight
    @gotoAndStop @tile
    @pos =
      x: x
      y: y

    @x = x * @tileWidth
    @y = y * @tileHeight

