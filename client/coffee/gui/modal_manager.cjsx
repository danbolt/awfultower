NewMap = require './modals/new_map'
OpenMap = require './modals/open_map'
EditLayer = require './modals/edit_layer'
Tilesheet = require './modals/tilesheet'

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
      when "open_map"
        <OpenMap {...@state.props} {...@props} />
      when "edit_layer"
        <EditLayer {...@state.props} {...@props} />
      when "tilesheet"
        <Tilesheet {...@state.props} {...@props} />

  render: ->
    cx = ""
    cx += " open" if @state.open
    <div id='modal-manager' className={cx} onClick={@close} ref="manager">
      { @renderModal() }
    </div>
