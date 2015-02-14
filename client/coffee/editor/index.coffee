Legend = require './legend'
Canvas = require './canvas'
Preload = require '../preload/load'
em = require '../event_manager'

GRID_COLOR = "#e5e5e5"

module.exports = class Editor
  constructor: (@delegate) ->

    @legendStage = new createjs.Stage 'legend-canvas'
    @sceneStage = new createjs.Stage 'scene-canvas'

    @legend = new Legend(@)
    @canvas = new Canvas(@)


    @legendStage.addChild @legend
    @sceneStage.addChild @canvas

    em.register 'keydown', @keydown

    @sceneStage.on 'stagemousedown', @canvas.stageMouseDown
    @sceneStage.on 'stagemouseup', @canvas.stageMouseUp

    # @addBrushControls()
    # @addGrid()

    createjs.Ticker.addEventListener 'tick', @legendStage
    createjs.Ticker.addEventListener 'tick', @sceneStage
    createjs.Ticker.addEventListener 'tick', @update
    createjs.Ticker.framerate = 60


  keydown: (e) =>
    if 48 < e.keyCode <= 57 # 48 is 0, 57 is 9
      @canvas.changeBrushSize e.keyCode - 48

  update: =>
    @canvas.update()

  tileSelected: (index) =>
    @canvas.changeTile index

