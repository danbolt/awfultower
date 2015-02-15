
module.exports = class Minimap extends createjs.Container
  constructor: ->
    super

  init: ->

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

        tile.x *= scale
        tile.y *= scale
        @addChild tile
        cb()

      , (err) =>
        return console.log "Error adding tile in minimap.coffe: #{err}" if err
        @stage.update()

module.exports = new Minimap()

