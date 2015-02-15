
module.exports = class Minimap extends createjs.Container
  constructor: ->
    super

  init: ->

  drawViewport: (data) =>
    {regX, regY, width, height, canvas, minX, minY} = data

    sx = @stage.canvas.width / width
    sy = @stage.canvas.height / height

    @removeChild @viewport
    g = new createjs.Graphics()
    g.setStrokeStyle(3)
    g.beginStroke("red")

    size = Math.min canvas.width * sx, canvas.height * sy

    x = (regX - minX)* sx
    y = (regY - minY)* sy

    g.drawRect(x, y, size, size)

    @viewport = new createjs.Shape g
    @addChild @viewport

    @stage.update()

  update: (data) =>
    @removeAllChildren()
    scaleX = @stage.canvas.width / data.width
    scaleY = @stage.canvas.height / data.height
    layers = data.layers

    scale = Math.min scaleX, scaleY
    for name, layer of layers
      async.each layer.children, (tile, cb) =>

        tile = _.clone tile
        tile.visible = true

        tile.scaleX = scale
        tile.scaleY = scale

        tile.x = (tile.x - data.minX)*scale
        tile.y = (tile.y - data.minY)*scale
        @addChild tile
        cb()

      , (err) =>
        return console.log "Error adding tile in minimap.coffe: #{err}" if err
        @stage.update()


module.exports = new Minimap()

