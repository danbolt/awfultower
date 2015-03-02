{tileWidth, tileHeight} = require './utils'

WIDTH = 256
HEIGHT = 256

MAP_SIZE = {x: 100, y: 100}

class Minimap
  constructor: ->
    @game = new Phaser.Game WIDTH, HEIGHT, Phaser.AUTO, "minimap",
      preload: @preload
      create: @create
      update: ->
      render: ->

    @tiles = {}

  init: (@delegate) =>

    # Scale the highlight area to represent size of the viewport
    @highlightSize = (@delegate.game.width / tileWidth) * (tileWidth * @scale.x)

    @highlight = @game.add.graphics()
    @highlight.lineStyle(2, 0xffff00, 1)
    @highlight.drawRect(0, 0, @highlightSize, @highlightSize)

  preload: =>
    @game.load.spritesheet('level', 'images/level3.png', tileWidth, tileHeight)

  create: =>
    @game.stage.backgroundColor = '#2d2d2d'
    @game.input.addMoveCallback @mouseMove, @

    @minimap = @game.add.group()
    # Scale is how much we need to scale each tile from the map -> minimap
    @scale =
      x: (WIDTH / MAP_SIZE.x) / tileWidth
      y: (HEIGHT / MAP_SIZE.y) / tileHeight

  # Mouse was clicked, update position of map
  mouseMove: (e) =>
    return unless @game.input.mousePointer.isDown
    x = (e.x / WIDTH)
    y = (e.y / HEIGHT)

    @delegate.moveCamera x, y

  # Moves the position of the highlight
  moveHighlight: (x,y) =>
    @highlight.x = x * tileWidth * @scale.x
    @highlight.y = y * tileHeight * @scale.y

  # Add a tile to the minimap. Just one layer of tiles (no alpha)
  addTile: (index, x, y) =>

    @tiles[x] ?= {}

    if @tiles[x][y]
      # Tile exists, swap indicies
      @tiles[x][y].frame = index
    else
      # Add a new tile
      sprite = @game.add.sprite x*@scale.x*tileWidth, y*@scale.y*tileHeight, 'level', index
      sprite.scale.setTo @scale.x, @scale.y

      @tiles[x][y] = sprite

      @minimap.add sprite

  # Fill an area
  fill: (tile, x, y, w, h) =>
    for i in [0..w-1]
      for j in [0..h-1]
        @addTile tile, x+i, y+j

  # Remove tile
  removeTile: (x,y) =>
    return unless (tile = @tiles[x]?[y])
    delete @tiles[x][y]
    @minimap.remove tile

module.exports = new Minimap()

