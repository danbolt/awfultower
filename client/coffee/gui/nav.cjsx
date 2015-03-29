
module.exports = React.createClass
  displayName: "Nav"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("StateStore")]

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store("StateStore").getState()

  toggleErase: ->
    @getFlux().actions.toggleErase()

  toggleGrid: ->
    @getFlux().actions.toggleGrid()

  newMapClick: ->
    @getFlux().actions.openModal 'new_map', {}

  openMapClick: ->
    @getFlux().actions.openModal 'open_map', {}

  renderErase: ->
    cx = "control fa fa-eraser"
    cx += " active" if @state.erase
    <li className={cx} onClick={@toggleErase} />

  renderGrid: ->
    cx = "control fa-stacked"
    cx += " active" if @state.grid

    <li className={cx} onClick={@toggleGrid}>
      <i className="fa fa-bars fa-stack-1x" />
      <i className="fa fa-bars fa-rotate-90 fa-stack-1x" />
    </li>

  renderOpen: ->
    <li className="control" onClick={@openMapClick} >
      <i className="fa fa-folder-open" />
    </li>

  renderNew: ->
    <li className="control" onClick={@newMapClick} >
      <i className="fa fa-plus-square" />
    </li>

  renderLogout: ->
    <li className="control">
      <a href="/logout" className="fa fa-sign-out" />
    </li>

  componentDidMount: ->
    $(window).keydown (e) =>
      return if @getFlux().stores.ModalStore.open
      if e.keyCode is 68
        @toggleErase()

  render: ->
    <ul id="hud">
      <li className="logo fa fa-map-marker" />
      { @renderErase() }
      { @renderGrid() }
      <div className="lower">
        { @renderOpen() }
        { @renderNew() }
        { @renderLogout() }
      </div>
    </ul>
