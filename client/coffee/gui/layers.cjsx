em = require '../event_manager'
Layer = require './layer'

module.exports = React.createClass
  displayName: "Layers Panel"

  getInitialState: ->
    layers: ["layer 1"]
    currentLayer: "layer 1"

  layerSelected: (layer) ->
    @setState(currentLayer: layer) if layer in @state.layers

  addLayer: ->
    layers = @state.layers
    layer = "layer #{layers.length + 1}"
    layers.push layer

    @setState {layers: layers, currentLayer: layer}, ->
      em.call 'add-layer', [layer]

  render: ->
    <div className="panel layers">
      <h2>
        LAYERS
        <button className="add-layer fa fa-plus" onClick={@addLayer} />
      </h2>

      <ul>
        {
          for layer in @state.layers
            current = layer is @state.currentLayer
            <Layer name={layer} key={layer} current={current} layerSelected={@layerSelected}/>

        }
      </ul>
    </div>


