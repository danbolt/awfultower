em = require '../event_manager'
Layer = require './layer'

module.exports = React.createClass
  displayName: "Layers Panel"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("Store")]

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store("Store").getState()

  layerSelected: (layer) ->
    @setState(currentLayer: layer) if layer in @state.layers

  addLayer: ->
    layers = @state.layers
    layer = "layer #{Object.keys(layers).length + 1}"

    @getFlux().actions.addLayer layer

  componentDidMount: ->
    @getFlux().actions.addLayer "layer 1"
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
    @getFlux().actions.reorderLayers layers

  render: ->

    layers = _.values @state.layers
    layers = _.sortBy layers, "order"

    <div className="panel layers">
      <h2>
        LAYERS
        <button className="add-layer fa fa-plus" onClick={@addLayer} />
      </h2>

      <ul ref="list">
        {
          for layer in layers
            <Layer layer={layer} key={Math.random()} layerSelected={@layerSelected} flux={@props.flux} />
        }
      </ul>
    </div>


