em = require '../event_manager'

module.exports = React.createClass
  displayName: "Nav"
  getInitialState: ->
    gridOn: true
    eraseOn: false

  toggleErase: ->
    eraseOn = not @state.eraseOn
    @setState eraseOn: eraseOn

    em.call 'toggle-erase', [eraseOn]

  toggleGrid: ->
    gridOn = not @state.gridOn
    @setState gridOn: gridOn

    em.call 'toggle-grid', [gridOn]

  renderGrid: ->
    cx = "control fa fa-table"
    cx += " active" if @state.gridOn
    <li className={cx} onClick={@toggleGrid} />

  renderErase: ->
    cx = "control fa fa-eraser"
    cx += " active" if @state.eraseOn
    <li className={cx} onClick={@toggleErase} />

  render: ->
    <ul id="hud">
      <li className="logo fa fa-rocket" />
      { @renderGrid() }
      { @renderErase() }
    </ul>
