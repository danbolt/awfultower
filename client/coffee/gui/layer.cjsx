module.exports = React.createClass
  displayName: "Layer"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("Store")]

  getStateFromFlux: ->
    @getFlux().store("Store").getState()

  changeLayer: (e) ->
    @getFlux().actions.changeLayer @props.layer.name

  hideLayer: (e) ->
    @getFlux().actions.toggleLayerVisible @props.layer.name
    e.stopPropagation()

  lockLayer: (e) ->
    @getFlux().actions.toggleLayerLocked @props.layer.name
    e.stopPropagation()

  render: ->
    layer = @props.layer
    cx = "layer"
    cx += " hidden" unless layer.visible
    cx += " locked" if layer.locked
    cx += " current" if @state.currentLayer is layer.name

    <li className={cx} onClick={@changeLayer} data-name={layer.name}>
      {layer.name}
      <div className="controls">
        <div className="fa fa-eye visibility" onClick={@hideLayer} />
        <div className="fa fa-lock locked" onClick={@lockLayer} />
      </div>
    </li>
