{tileWidth, tileHeight} = require './utils'

WIDTH = 256
HEIGHT = 256

class Minimap
  constructor: ->
    @game = new Phaser.Game WIDTH, HEIGHT, Phaser.AUTO, "minimap",
      preload: @preload
      create: @create
      update: ->
      render: ->

    @tiles = {}

    @scale =
      x: (WIDTH / 100) / tileWidth
      y: (HEIGHT / 100) / tileHeight

  setScale: (x, y) =>
    @scale =
      x: (WIDTH / x) / tileWidth
      y: (HEIGHT / y) / tileHeight

  init: (@delegate) ->
    @highlight = @game.add.graphics()
    @resizeHighlight()

  preload: =>
    @game.load.spritesheet 'level', 'images/level3.png', tileWidth, tileHeight

  create: =>
    @game.stage.backgroundColor = '#2d2d2d'
    @game.input.addMoveCallback @mouseMove, @

    @minimap = @game.add.group()

  resizeHighlight: ->
    return unless @delegate
    x = (@delegate.game.width / tileWidth) * (tileWidth * @scale.x)
    y = (@delegate.game.height / tileHeight) * (tileHeight * @scale.y)

    @highlight.clear()
    @highlight.lineStyle 2, 0xffff00, 1
    @highlight.drawRect 0, 0, x, y

  # Mouse was clicked, update position of map
  mouseMove: (e) =>
    return unless @game.input.mousePointer.isDown
    x = e.x / WIDTH
    y = e.y / HEIGHT

    @delegate.moveCamera x, y

  moveHighlight: (x,y) ->
    @highlight.x = x * tileWidth * @scale.x
    @highlight.y = y * tileHeight * @scale.y

  # Add a tile to the minimap. Just one layer of tiles (no alpha)
  addTile: (index, x, y) ->

    @tiles[x] ?= {}

    if @tiles[x][y]
      # Tile exists, swap indicies
      @tiles[x][y].frame = index
    else
      # Add a new tile
      _x = x * @scale.x * tileWidth
      _y = y * @scale.y * tileHeight

      sprite = @game.add.sprite _x, _y, 'level', index
      sprite.scale.setTo @scale.x, @scale.y

      @tiles[x][y] = sprite

      @minimap.add sprite

  # Fill an area
  fill: (tile, x, y, w, h) ->
    for i in [0..w - 1]
      for j in [0..h - 1]
        @addTile tile, x + i, y + j

  # Remove tile
  removeTile: (x,y) ->
    return unless (tile = @tiles[x]?[y])
    delete @tiles[x][y]
    @minimap.remove tile

module.exports = new Minimap()

