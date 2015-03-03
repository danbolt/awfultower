Nav = require './nav'
Layers = require './layers'
Legend = require './legend'
QuickSelect = require './quick_select'

{tileWidth, tileHeight} = require '../editor/utils'

module.exports = React.createClass
  displayName: "Main"

  getInitialState: ->
    {}

  # When we resize the window, calculate how big the canvas should be
  resizeScene: ->
    scene = $(@refs.scene.getDOMNode())
    nav = $(@refs.nav.getDOMNode())
    panels = $(@refs.panels.getDOMNode())
    quickSelect = $(@refs.quickSelect.getDOMNode())

    body = $("body")

    w = body.width() - (nav.width() + panels.width() + 32*3)
    h = body.height() - (quickSelect.height() + 32*3)

    @setState sceneWidth: Math.floor(w/32)*32, sceneHeight: Math.floor(h/32)*32

  componentDidMount: ->
    $(window).resize (e) =>
      @resizeScene()

    @resizeScene()

  render: ->

    sceneStyles =
      width: @state.sceneWidth
      height: @state.sceneHeight

    <div>
      <Nav flux={@props.flux} ref="nav" />
      <div  id="scene" ref="scene" style={sceneStyles}/>

      <section id="panels" ref="panels" >
        <Legend flux={@props.flux} />
        <div className="panel minimap">
          <h2> MINIMAP </h2>
          <div id="minimap" />
        </div>

        <Layers flux={@props.flux} />
      </section>
      <QuickSelect ref="quickSelect" flux={@props.flux} />
    </div>
