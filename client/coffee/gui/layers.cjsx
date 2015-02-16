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

  componentDidMount: ->
    @sortable()

  sortable: ->
    $list = $(@refs.list.getDOMNode())
    height = $list.first().height()

    $list.sortable
      axis: "y"
      containment: "parent"
      stop: @sorted
      tolerance: "pointer"
      forcePlaceholderSize: true
      placeholder: "sortable-placeholder"
      grid: [0, height]

    $list.disableSelection()

  sorted: (e, ui) ->
    layers = $(@refs.list.getDOMNode()).children("li")
    layers = layers.map (index, layer) =>
      $(layer).data "name"

    layers = $.makeArray(layers)

    @setState {layers: layers}, ->
      em.call 'reorder-layers', [layers]

  render: ->
    <div className="panel layers">
      <h2>
        LAYERS
        <button className="add-layer fa fa-plus" onClick={@addLayer} />
      </h2>

      <ul ref="list">
        {
          for layer, i in @state.layers
            current = layer is @state.currentLayer
            <Layer name={layer} key={Math.random()} current={current} layerSelected={@layerSelected}/>
        }
      </ul>
    </div>


