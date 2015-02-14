em = require '../event_manager'

module.exports = React.createClass
  displayName: "Layers Panel"

  getInitialState: ->
    layers: ["layer 1"]

  addLayer: ->
    console.log "ASD"
    layers = @state.layers
    layer = "layer #{layers.length + 1}"
    layers.push layer

    @setState layers: layers, ->
      em.call 'add-layer', [layer]

  changeLayer: (e) ->
    layer = $(e.target).closest('li').data('name')
    em.call 'change-layer', [layer]

  hideLayer: (e) ->
    layer = $(e.target).closest('li').data('name')
    em.call 'hide-layer', [layer]

  lockLayer: (e) ->
    layer = $(e.target).closest('li').data('name')
    em.call 'lock-layer', [layer]

  render: ->
    <div className="panel layers">
      <h2>
        LAYERS
        <button className="add-layer fa fa-plus" onClick={@addLayer} />
      </h2>

      <ul>
        {
          for layer in @state.layers
            <li className="layer" key={layer} onClick={@changeLayer} data-name={layer}>
              {layer}
              <div className="controls">
                <i className="fa fa-eye" onClick={@hideLayer} />
                <i className="fa fa-lock" onClick={@lockLayer} />
              </div>
            </li>
        }
      </ul>
    </div>


