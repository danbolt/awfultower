Nav = require './nav'
Layers = require './layers'

module.exports = React.createClass
  displayName: "Main"
  render: ->
    <div>
      <Nav />
      <canvas id="scene-canvas" width="800" height="800"></canvas>
      <section id="panels">
        <div className="panel legend">
          <h2> TILES </h2>
          <canvas id="legend-canvas" width="256" height="320"></canvas>
        </div>

        <div className="panel minimap">
          <h2> MINIMAP </h2>
          <canvas id="minimap-canvas" width="256" height="256"></canvas>
        </div>

        <Layers />

      </section>
    </div>
