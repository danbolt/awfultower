module.exports = React.createClass
  displayName: "Layer"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("LayerStore")]

  getStateFromFlux: ->
    @getFlux().store("LayerStore").getState()

  changeLayer: (e) ->
    @getFlux().actions.changeLayer @props.layer.id

  hideLayer: (e) ->
    @getFlux().actions.toggleLayerVisible @props.layer.id
    e.stopPropagation()

  lockLayer: (e) ->
    @getFlux().actions.toggleLayerLocked @props.layer.id
    e.stopPropagation()

  editLayer: (e) ->
    @getFlux().actions.openModal 'edit_layer', {layer: @props.layer}
    e.stopPropagation()

  render: ->
    layer = @props.layer
    cx = "layer"
    cx += " hidden" unless layer.visible
    cx += " locked" if layer.locked
    cx += " current" if @state.currentLayer is layer.id

    eye = if layer.visible then "eye" else "eye-slash"
    lock = if layer.locked then "lock" else "unlock-alt"

    <li className={cx} onClick={@changeLayer} data-id={layer.id}>
      {layer.name}
      <div className="controls">
        <button className="fa fa-#{eye} visibility" onClick={@hideLayer} />
        <button className="fa fa-#{lock} locked" onClick={@lockLayer} />
        <button className="fa fa-pencil" onClick={@editLayer} />
      </div>
    </li>
