Scene = require '../scene'
Legend = require './legend'
Canvas = require './canvas'
LevelData = require '../level_data'
Preload = require '../preload/load'
BrushControls = require './brush_controls'

GRID_COLOR = "#e5e5e5"
CANVAS_X = 400 - LevelData.tileWidth / 2

module.exports = class Editor extends Scene
  constructor: (@delegate) ->
    super @delegate
    @legend = new Legend(@)
    @canvas = new Canvas(@)

    @canvas.x = CANVAS_X

    @addChild @legend
    @addChild @canvas

    @canvas.width = @delegate.stage.canvas.width - CANVAS_X
    @canvas.height = @delegate.stage.canvas.height

    $(window).keydown (e) =>
      if 48 < e.keyCode <= 57 # 48 is 0, 57 is 9
        @canvas.brushSize = e.keyCode - 48
        @brushControls.updateBrushSize(@canvas.brushSize)

    @delegate.stage.on 'stagemousedown', @canvas.stageMouseDown
    @delegate.stage.on 'stagemouseup', @canvas.stageMouseUp

    @tileWidth = LevelData.tileWidth
    @tileHeight = LevelData.tileHeight

    @addBrushControls()
    @addGrid()

  update: ->
    @canvas.update()

  addBrushControls: ->
    @brushControls = new BrushControls(@)

    @brushControls.x = 10
    @brushControls.y = 400
    @addChild @brushControls

  tileSelected: (index) =>
    @canvas.tile = index

  brushSelected: (brush) =>
   @canvas.brush = brush

  addGrid: ->

    for i in [CANVAS_X..@delegate.stage.canvas.width] by @tileWidth

      line = new createjs.Shape()
      line.graphics.setStrokeStyle(1)
      line.graphics.beginStroke(GRID_COLOR)
      line.graphics.moveTo(i, 0)
      line.graphics.lineTo(i, @delegate.stage.canvas.height)
      @addChild(line)

    for i in [0..@delegate.stage.canvas.height] by @tileHeight

      line = new createjs.Shape()
      line.graphics.setStrokeStyle(1)
      line.graphics.beginStroke(GRID_COLOR)
      line.graphics.moveTo(CANVAS_X, i)
      line.graphics.lineTo(@delegate.stage.canvas.width, i)
      @addChild(line)
