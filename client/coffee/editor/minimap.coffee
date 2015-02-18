{tileWidth, tileHeight} = require './utils'

module.exports = class Minimap extends createjs.Container
  constructor: ->
    super

    @tiles = {}

  scale: ->
    canvasWidth = @canvas.mapWidth() * tileWidth
    canvasHeight = @canvas.mapHeight() * tileHeight

    width = @stage.canvas.width
    height = @stage.canvas.height

    Math.min(width / canvasWidth, height / canvasHeight)

  updateContainer: ->
    scale = @scale()
    bounds = @canvas.bounds()

    minX = Math.min(bounds.minX, @canvas.regX / tileWidth)
    minY = Math.min(bounds.minY, @canvas.regY / tileHeight)

    @regX = minX * tileWidth
    @regY = minY * tileHeight

    @scaleX = scale
    @scaleY = scale

    @stage.update()

  stageMouseDown: (e) =>

    @canvas.hideViewportTiles()

    @canvas.regX = Math.floor((e.stageX / @scale() + @regX - @canvas.stage.canvas.width / 2) / tileWidth) * tileWidth
    @canvas.regY = Math.floor((e.stageY / @scale() + @regY - @canvas.stage.canvas.height / 2) / tileHeight) * tileHeight

    @canvas.showViewportTiles()

    @drawViewport()

  drawViewport:  =>
    g = new createjs.Graphics().setStrokeStyle( 3 / @scale() ).beginStroke("red")

    size = Math.min @canvas.stage.canvas.width, @canvas.stage.canvas.height

    g.drawRect(@canvas.regX, @canvas.regY, size, size)

    @removeChild @viewport
    @viewport = new createjs.Shape g
    @addChild @viewport

    @updateContainer()

  addTiles: (tiles) =>
    return unless tiles?.length
    for tile in tiles
      tile = _.clone tile
      tile.visible = true

      {x,y} = tile.pos

      @tiles[x] ||= {}
      existingTile = @tiles[x][y]

      if existingTile
        if existingTile.tile isnt tile.tile
          @removeChild existingTile
          @addChild tile
          @tiles[x][y] = tile
      else
        @addChild tile
        @tiles[x][y] = tile

    @drawViewport()
    @updateContainer()

  removeTiles: (tiles) =>
    return unless tiles?.length
    for tile in tiles
      {x,y} = tile.pos

      continue unless (t = @tiles[x]?[y])

      @removeChild t
      delete @tiles[x][y]

    @drawViewport()
    @updateContainer()

module.exports = new Minimap()


