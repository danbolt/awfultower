
{tileWidth, tileHeight} = require './utils'

module.exports = class Grid
  constructor: (@delegate) ->
    @game = @delegate.game

    @group = @game.add.group()

    @horiz = @game.add.graphics()
    @vert = @game.add.graphics()

    @group.add @horiz
    @group.add @vert

    @drawGrid()


  resizeGrid: ->
    @horiz.clear()
    @vert.clear()

    @drawGrid()

  drawGrid: ->

    # The horizontal and vertical lines are drawn in a serpentine pattern
    @horiz.lineStyle(1,0x3d3d3d, 1)
    @horiz.moveTo 0, 0

    for i in [0..@game.height] by tileWidth
      @horiz.lineTo @game.width, i
      @horiz.moveTo 0, i + tileWidth

    @vert.lineStyle(1,0x3d3d3d, 1)
    @vert.moveTo 0, 0

    for i in [0..@game.width] by tileHeight
      @vert.lineTo i, @game.height
      @vert.moveTo i + tileHeight, 0


  toggle: (grid) ->
    @horiz.visible = grid
    @vert.visible = grid

  # The grid is small. Only the size of the canvas. Move it as the camera moves
  move: (x, y) ->
    @horiz.x = x
    @horiz.y = y

    @vert.x = x
    @vert.y = y
