ModalMixin = require '../mixins/modal'
ServerAgent = require '../../editor/server_agent'

module.exports = React.createClass
  displayName: "EditLayerModel"
  mixins: [ModalMixin, React.addons.LinkedStateMixin]

  config:
    className: "edit-layer"
    title: "Edit Layer"

  getInitialState: ->
    {}

  cancel: (e) ->
    @close()
    e.preventDefault()

  getInitialState: ->
    name: @props.layer.name

  nameChange: (e) ->
    @setState name: e.target.value

  delete: (e) ->
    ServerAgent.send 'remove_layer', {layerId: @props.layer.id}
    @close()
    e.preventDefault()

  submit: (e) ->
    e.preventDefault()

    return unless @state.name isnt @props.layer.name

    ServerAgent.send 'rename_layer',
      { layerId: @props.layer.id, name: @state.name }

  renderContent: ->
    <div>
      <form className="form">
        <fieldset>
          <label> Name </label>
          <input type="text" onClick={@nameChange} valueLink={@linkState('name')} />
        </fieldset>
        <button className="delete" onClick={@delete}> Delete Layer </button>
        <div className="controls">
          <button className="cancel" onClick={@cancel}> Cancel </button>
          <button className="submit" onClick={@submit}> Save </button>
        </div>
      </form>
    </div>
