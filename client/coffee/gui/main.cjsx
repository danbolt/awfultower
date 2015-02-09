Nav = require './nav'

module.exports = React.createClass
  render: ->
    <div>
      <Nav />
      <canvas id="legend-canvas" width="300" height="900"></canvas>
      <canvas id="scene-canvas" width="1100" height="900"></canvas>
    </div>
