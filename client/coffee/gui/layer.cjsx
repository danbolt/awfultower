em = require '../event_manager'

module.exports = React.createClass
  displayName: "Layer"

  getInitialState: ->
    locked: false
    visible: true

  changeLayer: (e) ->
    @props.layerSelected @props.name
    em.call 'change-layer', [@props.name]

  hideLayer: (e) ->
    @setState visible: not @state.visible
    em.call 'hide-layer', [@props.name]
    e.stopPropagation()

  lockLayer: (e) ->
    @setState locked: not @state.locked
    em.call 'lock-layer', [@props.name]
    e.stopPropagation()

  render: ->
    cx = "layer"
    cx += " hidden" unless @state.visible
    cx += " locked" if @state.locked
    cx += " current" if @props.current

    <li className={cx} onClick={@changeLayer} data-name={@props.name}>
      {@props.name}
      <div className="controls">
        <div className="fa fa-eye visibility" onClick={@hideLayer} />
        <div className="fa fa-lock locked" onClick={@lockLayer} />
      </div>
    </li>
