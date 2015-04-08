ModalMixin = require '../mixins/modal'
ServerAgent = require '../../editor/server_agent'

module.exports = React.createClass
  displayName: "TilesheetModal"
  mixins: [ModalMixin, React.addons.LinkedStateMixin]

  config:
    className: "tilesheet"
    title: "Tilesheets"

  getInitialState: ->
    {}

  cancel: (e) ->
    @close()
    e.preventDefault()

  submit: (e) ->
    e.preventDefault()
    @close()

  renderContent: ->
    <div>
      <form className="form">

        <div className="controls">
          <button className="cancel" onClick={@cancel}> Cancel </button>
          <button className="submit" onClick={@submit}> Save </button>
        </div>

      </form>
    </div>
