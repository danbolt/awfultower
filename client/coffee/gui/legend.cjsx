Stamp = require '../editor/lib/stamp'
em = require '../event_manager'
{tileWidth, tileHeight} = require '../editor/utils'

module.exports = React.createClass
  displayName: "Legend"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("Store")]

  isMouseDown: false
  initialMousePosition: {}

  getInitialState: ->
    highlightStyle:
      left: 0
      top: 0
      width: tileWidth
      height: tileHeight

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store("Store").getState()

  position: (e) ->
    parent = @refs.panel.getDOMNode()
    headerHeight = $(@refs.panel.getDOMNode()).children('h2').outerHeight()

    x: Math.floor (e.clientX - parent.offsetLeft) / tileWidth
    y: Math.floor (e.clientY - (parent.offsetTop + headerHeight)) / tileHeight

  width: ->
    @refs.image.getDOMNode().width / tileWidth

  mouseDown: (e) ->
    @isMouseDown = true
    @initialMousePosition = @position e

  mouseUp: (e) ->
    {x,y} = @position e
    initial = @initialMousePosition
    w = @width()

    minX = if x <= initial.x then x else initial.x
    maxX = if x >= initial.x then x else initial.x
    minY = if y <= initial.y then y else initial.y
    maxY = if y >= initial.y then y else initial.y

    if x is initial.x and y is initial.y
      Stamp.setSingle y*w + x
    else
      tiles = []
      for i in [minX..maxX]
        _tiles = []
        for j in [minY..maxY]
          _tiles.push j*w + i
        tiles.push _tiles

      Stamp.setMultiple tiles

    @setState highlightStyle:
      left: minX * tileWidth
      top: minY * tileHeight
      width: ((maxX - minX) + 1) * tileWidth
      height: ((maxY - minY) + 1) * tileHeight

    @getFlux().actions.toggleErase false

  render: ->
    <div className="panel legend" ref="panel">
      <h2>
        TILES
      </h2>
      <div className="imageContainer">
        <img src="images/level3.png" ref="image"/>
        <div className="mask" onMouseUp={@mouseUp} onMouseDown={@mouseDown}>
          <div className="highlight" style={@state.highlightStyle}/>
        </div>
      </div>
    </div>


