em = require '../event_manager'

module.exports = React.createClass
  getInitialState: ->
    gridOn: true

  toggleGrid: ->
    gridOn = not @state.gridOn
    @setState gridOn: gridOn

    em.call em.types.toggleGrid, [gridOn]

  renderGrid: ->
    cx = "control fa fa-table"
    cx += " active" if @state.gridOn
    <li className={cx} onClick={@toggleGrid} />

  render: ->
    <ul id="hud">
      <li className="logo fa fa-rocket" />
      { @renderGrid() }
    </ul>
