Nav = require './nav'
Layers = require './layers'
Legend = require './legend'

module.exports = React.createClass
  displayName: "Main"
  render: ->
    <div>
      <Nav flux={@props.flux} />
      <div id="scene"></div>
      <section id="panels">
        <Legend flux={@props.flux} />
        <div className="panel minimap">
          <h2> MINIMAP </h2>
          <div id="minimap" />
        </div>

        <Layers flux={@props.flux} />

      </section>
    </div>
