
module.exports = React.createClass
  displayName: "Nav"
  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("Store")]

  getStateFromFlux: ->
    flux = @getFlux()
    flux.store("Store").getState()

  toggleErase: ->
    @getFlux().actions.toggleErase()

  renderErase: ->
    cx = "control fa fa-eraser"
    cx += " active" if @state.erase
    <li className={cx} onClick={@toggleErase} />

  componentDidMount: ->
    $(window).keydown (e) =>
      if e.keyCode is 68
        @toggleErase()

  render: ->
    <ul id="hud">
      <li className="logo fa fa-rocket" />
      { @renderErase() }
    </ul>
