Nav = require './nav'

module.exports = React.createClass
  render: ->
    <div>
      <Nav />
      <canvas id="scene-canvas" width="800" height="800"></canvas>
      <section id="panels">
        <div className="panel legend">
          <h2> TILES </h2>
          <canvas id="legend-canvas" width="256" height="320"></canvas>
        </div>

        <div className="panel layers">
          <h2> LAYERS </h2>
          <canvas height="200" width="256" style={{border: "solid 2px black", "background-color":"white"}}> </canvas>
        </div>

      </section>
    </div>
