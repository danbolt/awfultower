Preload = require '../preload/load'

BUTTON_Y = 50
BRUSHES =
  square: {x: 0, y: 0}
  horizontal: {x:1, y: 0}
  vertical: {x: 0, y: 1}

BRUSH_TYPES = ['square', 'horizontal', 'vertical']

class Button extends createjs.Container
  constructor: (x, y, imageName, @delegate) ->
    super
    @x = x
    @y = y

    img = new createjs.Bitmap("images/#{imageName}")
    img.x = 0
    img.y = 0

    g = new createjs.Graphics()
    @color = g.beginFill("white").command

    g.drawRect(0, 0, 16, 16)
    @background = new createjs.Shape(g)

    @addChild(@background)
    @addChild(img)

    @on("click", @click)

  click: =>
    @delegate.brushClick(@)

  activate: =>
    @delegate.activeBrush.color.style = "#ffffff"
    @color.style = "#ff0000"
    @delegate.activeBrush = @

module.exports = class BrushControls extends createjs.Container
  constructor: (@delegate) ->
    super

    text = new createjs.Text("Brush", "20px Arial", "#000000")
    text.x = 10
    text.y = 10

    @addChild(text)

    @square = new Button(10, BUTTON_Y, "brush-square.png", @)
    @horizontal = new Button(50, BUTTON_Y, "brush-horizontal.png", @)
    @vertical = new Button(90, BUTTON_Y, "brush-vertical.png", @)

    @activeBrush = @square
    @square.color.style = "#ff0000"

    @addChild(@square)
    @addChild(@horizontal)
    @addChild(@vertical)

    @label = new createjs.Text("Size: 1", "18px Arial", "#000000")
    @label.x = 100
    @label.y = 10

    @addChild(@label)

  updateBrushSize: (size) ->
    @label.text = "Size: #{size}"

  brushClick: (button) ->
    for brush in BRUSH_TYPES
      if button is @[brush]
        button.activate()
        return @delegate.brushSelected(BRUSHES[brush])


