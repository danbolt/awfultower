
{tileWidth, tileHeight} = require './utils'

module.exports = class Minimap extends createjs.Container
  constructor: ->
    super

  init: ->

  stageMouseDown: (e) =>
    canvasWidth = @canvas.mapWidth() * tileWidth
    canvasHeight = @canvas.mapHeight() * tileHeight

    bounds = @canvas.bounds()

    width = @stage.canvas.width
    height = @stage.canvas.height

    scale = Math.min(width / canvasWidth, height / canvasHeight)

    @canvas.hideViewportTiles()

    @canvas.regX = Math.floor((e.stageX / scale + @regX - @canvas.stage.canvas.width / 2) / tileWidth) * tileWidth
    @canvas.regY = Math.floor((e.stageY / scale + @regY - @canvas.stage.canvas.height / 2) / tileHeight) * tileHeight

    @canvas.showViewportTiles()

    @drawViewport()

  stageMouseUp: (e) =>

  recalculate:  (tiles) =>
    @addTiles tiles
    @drawViewport()

  drawViewport:  =>
    canvasWidth = @canvas.mapWidth() * tileWidth
    canvasHeight = @canvas.mapHeight() * tileHeight

    bounds = @canvas.bounds()

    width = @stage.canvas.width
    height = @stage.canvas.height

    scale = Math.min(width / canvasWidth, height / canvasHeight)

    minX = Math.min(bounds.minX, @canvas.regX / tileWidth)
    minY = Math.min(bounds.minY, @canvas.regY / tileHeight)

    g = new createjs.Graphics()
    g.setStrokeStyle(3 / scale)
    g.beginStroke("red")

    size = Math.min @canvas.stage.canvas.width, @canvas.stage.canvas.height
    x = (@canvas.regX )
    y = (@canvas.regY )

    g.drawRect(x,y, size, size)

    @removeChild @viewport
    @viewport = new createjs.Shape g

    @addChild @viewport
    @scaleX = scale
    @scaleY = scale

    @regX = minX * tileWidth
    @regY = minY * tileHeight

    @stage.update()

  addTiles: (tiles) =>
    canvasWidth = @canvas.mapWidth() * tileWidth
    canvasHeight = @canvas.mapHeight() * tileHeight

    bounds = @canvas.bounds()

    width = @stage.canvas.width
    height = @stage.canvas.height

    scale = Math.min(width / canvasWidth, height / canvasHeight)

    minX = Math.min(bounds.minX, @canvas.regX / tileWidth)
    minY = Math.min(bounds.minY, @canvas.regY / tileHeight)

    layers = @canvas.layers

    async.each tiles, (tile, cb) =>

      tile = _.clone tile
      tile.visible = true

      tile.x = (tile.x )
      tile.y = (tile.y )

      @addChild tile
      cb()

    , (err) =>
      return console.log "Error adding tile in minimap.coffe: #{err}" if err
      @regX = minX * tileWidth
      @regY = minY * tileHeight
      @scaleX = scale
      @scaleY = scale
      @stage.update()

module.exports = new Minimap()

