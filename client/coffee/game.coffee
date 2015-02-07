Preload = require './preload/load'
Level = require './level'
Editor = require './editor'

class Game
  constructor: ->
    Preload.start @loadComplete
    @throttle = 0

  loadComplete: =>
    # @stage = new createjs.Stage 'legend-canvas'

    @editor = new Editor @
    # @editor.show()


  tick: (e) =>
    @scene.update()
    @stage.update()

  showScene: (scene) =>
    @stage.removeChild @scene
    @stage.addChild scene
    @scene = scene

module.export = new Game()

