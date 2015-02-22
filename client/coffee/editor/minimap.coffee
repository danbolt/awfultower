{tileWidth, tileHeight} = require './utils'

WIDTH = 256
HEIGHT = 256

MAP_SIZE = {x: 100, y: 100}

class Minimap
  constructor: ->
    @game = new Phaser.Game WIDTH, HEIGHT, Phaser.AUTO, "minimap",
      preload: @preload
      create: @create
      update: @update
      render: @render

    @tiles = {}

  init: (@delegate) =>

  mouseMove: (e) =>
    return unless @game.input.mousePointer.isDown
    x = (e.x / 256)
    y = (e.y / 256)

    @delegate.moveCamera x, y

  preload: =>

    @game.load.spritesheet('level', 'images/level3.png', tileWidth, tileHeight)

  create: =>
    @game.stage.backgroundColor = '#2d2d2d'
    @game.input.addMoveCallback @mouseMove, @

    @minimap = @game.add.group()
    @scale =
      x: (WIDTH / MAP_SIZE.x) / tileWidth
      y: (HEIGHT / MAP_SIZE.y) / tileHeight

    @highlightSize = (800 / tileWidth) * (tileWidth * @scale.x)

    @highlight = @game.add.graphics()
    @highlight.lineStyle(2, 0xffff00, 1)
    @highlight.drawRect(0, 0, @highlightSize, @highlightSize)

  update: =>
  render: =>

  moveHighlight: (x,y) =>
    @highlight.x = x * tileWidth * @scale.x
    @highlight.y = y * tileHeight * @scale.y

  addTile: (index, x, y) =>

    @tiles[x] ?= {}

    if @tiles[x][y]
      @tiles[x][y].frame = index
    else
      sprite = @game.add.sprite x*@scale.x*tileWidth, y*@scale.y*tileHeight, 'level', index
      sprite.scale.setTo @scale.x, @scale.y

      @tiles[x][y] = sprite

      @minimap.add sprite

  fill: (tile, x, y, w, h) =>
    for i in [0..w-1]
      for j in [0..h-1]
        @addTile tile, x+i, y+j

  removeTile: (x,y) =>
    return unless (tile = @tiles[x]?[y])
    delete @tiles[x][y]
    @minimap.remove tile

module.exports = new Minimap()

