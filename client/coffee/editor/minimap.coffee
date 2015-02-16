
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

    @canvas.regX = Math.floor((e.stageX / scale - @canvas.stage.canvas.width / 2) / tileWidth) * tileWidth
    @canvas.regY = Math.floor((e.stageY / scale - @canvas.stage.canvas.height / 2) / tileHeight) * tileHeight

    @canvas.showViewportTiles()

    @recalculate()

  stageMouseUp: (e) =>

  recalculate:  =>
    @removeAllChildren()

    @addTiles()
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
    g.setStrokeStyle(3)
    g.beginStroke("red")

    size = Math.min @canvas.stage.canvas.width * scale, @canvas.stage.canvas.height * scale
    x = (@canvas.regX - minX*tileWidth) * scale
    y = (@canvas.regY - minY*tileHeight) * scale

    g.drawRect(x,y, size, size)

    @removeChild @viewport
    @viewport = new createjs.Shape g

    @addChild @viewport
    @stage.update()

  addTiles:  =>
    canvasWidth = @canvas.mapWidth() * tileWidth
    canvasHeight = @canvas.mapHeight() * tileHeight

    bounds = @canvas.bounds()

    width = @stage.canvas.width
    height = @stage.canvas.height

    scale = Math.min(width / canvasWidth, height / canvasHeight)

    minX = Math.min(bounds.minX, @canvas.regX / tileWidth)
    minY = Math.min(bounds.minY, @canvas.regY / tileHeight)

    layers = @canvas.layers

    for name, layer of layers
      async.each layer.children, (tile, cb) =>

        tile = _.clone tile
        tile.visible = true

        tile.scaleX = scale
        tile.scaleY = scale

        tile.x = (tile.x - minX*tileWidth)*scale
        tile.y = (tile.y - minY*tileHeight)*scale

        @addChild tile
        cb()

      , (err) =>
        return console.log "Error adding tile in minimap.coffe: #{err}" if err
        @stage.update()


module.exports = new Minimap()

