# The grid that will be displayed in the canvas

{tileWidth, tileHeight} = require './utils'

module.exports = class Grid
  constructor: (@delegate) ->
    @game = @delegate.game

    @group = @game.add.group()

    # Horizontal and vertical line groups
    @horiz = @game.add.graphics()
    @vert = @game.add.graphics()

    @group.add @horiz
    @group.add @vert

    @drawGrid()

  # When the world resizes (window resize?) obliterate the grid and redraw it
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
  # making it appear that the grid fills the whole canvas
  move: (x, y) ->
    @horiz.x = x
    @horiz.y = y

    @vert.x = x
    @vert.y = y
