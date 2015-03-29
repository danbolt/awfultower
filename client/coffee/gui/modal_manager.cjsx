NewMap = require './modals/new_map'

module.exports = React.createClass
  displayName: "ModalManager"

  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("ModalStore")]

  getStateFromFlux: ->
    @getFlux().store("ModalStore").getState()

  close: (e) ->
    if e.target.id is 'modal-manager'
      @getFlux().actions.closeModal()

  renderModal: ->
    return unless @state.open
    return unless @state.type

    switch @state.type
      when "new_map"
        <NewMap {...@state.props} {...@props} />

  render: ->
    cx = ""
    cx += " open" if @state.open
    <div id='modal-manager' className={cx} onClick={@close} ref="manager">
      { @renderModal() }
    </div>
