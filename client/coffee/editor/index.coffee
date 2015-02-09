Legend = require './legend'
Canvas = require './canvas'
LevelData = require './lib/level_data'
Preload = require '../preload/load'

GRID_COLOR = "#e5e5e5"

module.exports = class Editor
  constructor: (@delegate) ->

    @legendStage = new createjs.Stage 'legend-canvas'
    @sceneStage = new createjs.Stage 'scene-canvas'

    @legend = new Legend(@)
    @canvas = new Canvas(@)


    @legendStage.addChild @legend
    @sceneStage.addChild @canvas

    $(window).keydown (e) =>
      if 48 < e.keyCode <= 57 # 48 is 0, 57 is 9
        @canvas.brushSize = e.keyCode - 48

    @sceneStage.on 'stagemousedown', @canvas.stageMouseDown
    @sceneStage.on 'stagemouseup', @canvas.stageMouseUp

    @tileWidth = LevelData.tileWidth
    @tileHeight = LevelData.tileHeight

    # @addBrushControls()
    # @addGrid()

    createjs.Ticker.addEventListener 'tick', @legendStage
    createjs.Ticker.addEventListener 'tick', @sceneStage
    createjs.Ticker.addEventListener 'tick', @update
    createjs.Ticker.framerate = 60

  update: =>
    @canvas.update()

  tileSelected: (index) =>
    @canvas.tile = index

