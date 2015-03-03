Stamp = require '../editor/lib/stamp'
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

  componentDidMount: ->
    $(window).keydown (e) =>
      @quickSelect = key - 48 if 48 <= (key = e.keyCode) <= 57
    $(window).keyup =>
      @quickSelect = null

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

  mouseMove: (e) ->
    if @isMouseDown
      @changeHighlight e

  mouseUp: (e) ->
    @isMouseDown = false
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

    @changeHighlight e
    @getFlux().actions.toggleErase false
    @getFlux().actions.addQuickSelect(@quickSelect, y*w + x) if @quickSelect?

  changeHighlight: (e) ->

    {x,y} = @position e
    initial = @initialMousePosition

    minX = if x <= initial.x then x else initial.x
    maxX = if x >= initial.x then x else initial.x
    minY = if y <= initial.y then y else initial.y
    maxY = if y >= initial.y then y else initial.y

    @setState highlightStyle:
      left: minX * tileWidth
      top: minY * tileHeight
      width: ((maxX - minX) + 1) * tileWidth
      height: ((maxY - minY) + 1) * tileHeight

  render: ->
    <div className="panel legend" ref="panel">
      <h2>
        TILES
      </h2>
      <div className="imageContainer">
        <img src="images/level3.png" ref="image"/>
        <div className="mask" onMouseUp={@mouseUp} onMouseDown={@mouseDown} onMouseMove={@mouseMove} >
          <div className="highlight" style={@state.highlightStyle}/>
        </div>
      </div>
    </div>


