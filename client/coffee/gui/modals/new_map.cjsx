ModalMixin = require '../mixins/modal'
ServerAgent = require '../../editor/server_agent'

module.exports = React.createClass
  displayName: "NewMapModel"
  mixins: [ModalMixin]

  config:
    className: "new-map"
    title: "New Map"

  getInitialState: ->
    {}

  nameChange: (e) ->
    @setState name: e.target.value

  widthChange: (e) ->
    @setState width: e.target.value

  heightChange: (e) ->
    @setState height: e.target.value

  cancel: (e) ->
    @close()
    e.preventDefault()

  submit: (e) ->
    if @state.name and @state.width and @state.height
      ServerAgent.send 'new_map',
        name: @state.name
        width: @state.width
        height: @state.height
      , (err, result) =>

        return console.log err if err
        if result.name
          window.location = "?map=#{result.name}"

      @close()

    e.preventDefault()

  renderContent: ->
    <div>
      <form className="form">
        <fieldset>
          <label>Name</label>
          <input type="text" onChange={@nameChange} />

          <label>Width (in tiles)</label>
          <input type="number" onChange={@widthChange} />

          <label>Height (in tiles)</label>
          <input type="number" onChange={@heightChange} />

        </fieldset>

        <div className="controls">
          <button className="cancel" onClick={@cancel}> Cancel </button>
          <button className="submit" onClick={@submit}> Create </button>
        </div>
      </form>
    </div>
