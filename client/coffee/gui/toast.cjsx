ServerAgent = require '../editor/server_agent'

module.exports = React.createClass
  displayName: "Toast"

  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("ToastStore")]

  getStateFromFlux: ->
    @getFlux().store("ToastStore").getState()

  getInitialState: -> {}

  render: ->
    return <div /> unless @state.message

    cx = "#{@state.type}" if @state.type
    # Add the message if there is one
    <div id="toast" className={cx}>
      {@state.message}
    </div>
