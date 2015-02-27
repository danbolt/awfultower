
{tileWidth, tileHeight} = require './utils'

module.exports = class Grid
  constructor: (@delegate) ->
    @game = @delegate.game

    # The horizontal and vertical lines are drawn in a serpentine pattern
    @horiz = @game.add.graphics()
    @horiz.lineStyle(1,0x3d3d3d, 1)
    @horiz.moveTo 0, 0

    for i in [0..800] by tileWidth
      @horiz.lineTo 800, i
      @horiz.moveTo 0, i + tileWidth

    @vert = @game.add.graphics()
    @vert.lineStyle(1,0x3d3d3d, 1)
    @vert.moveTo 0, 0

    for i in [0..800] by tileHeight
      @vert.lineTo i, 800
      @vert.moveTo i + tileHeight, 0

  toggle: (grid) ->
    line.visible = grid for line in @lines

  # The grid is small. Only the size of the canvas. Move it as the camera moves
  move: (x, y) ->
    @horiz.x = x
    @horiz.y = y

    @vert.x = x
    @vert.y = y

