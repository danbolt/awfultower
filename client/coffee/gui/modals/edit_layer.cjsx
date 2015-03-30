ModalMixin = require '../mixins/modal'
ServerAgent = require '../../editor/server_agent'

module.exports = React.createClass
  displayName: "EditLayerModel"
  mixins: [ModalMixin]

  config:
    className: "edit-layer"
    title: "Edit Layer"

  getInitialState: ->
    {}

  cancel: (e) ->
    @close()
    e.preventDefault()

  getInitialState: ->
    {}

  nameChange: (e) ->
    @setState name: e.target.value

  delete: (e) ->
    ServerAgent.send 'remove_layer', {layerId: @props.layer.id}
    @close()
    e.preventDefault()

  submit: (e) ->
    e.preventDefault()

  renderContent: ->
    <div>
      <form className="form">
        <fieldset>
          <label> Name </label>
          <input type="text" onClick={@nameChange} />
          <button className="delete" onClick={@delete}> Delete Layer </button>
        </fieldset>
        <div className="controls">
          <button className="cancel" onClick={@cancel}> Cancel </button>
          <button className="submit" onClick={@submit}> Save </button>
        </div>
      </form>
    </div>
