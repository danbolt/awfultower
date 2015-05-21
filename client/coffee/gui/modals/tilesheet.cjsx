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
      <form
        className="form"
        encType="multipart/form-data"
        action="tilesheet"
        method="post">
          <input type="file" name="tilesheet" />
          <input type="submit" value="Add Tilesheet" name="submit" />
      </form>
    </div>
