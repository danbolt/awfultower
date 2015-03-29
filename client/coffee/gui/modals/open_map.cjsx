ModalMixin = require '../mixins/modal'
ServerAgent = require '../../editor/server_agent'

module.exports = React.createClass
  displayName: "OpenMapModel"
  mixins: [ModalMixin]

  config:
    className: "open-map"
    title: "Open Map"

  getInitialState: ->
    {}

  cancel: (e) ->
    @close()
    e.preventDefault()

  componentDidMount: ->
    ServerAgent.send 'get_maps', null, (err, result) =>
      return console.log err if err
      @setState maps: result.maps

  submit: (e) ->
    e.preventDefault()
    return unless (name = @state.selectedMap?.name)
    window.location = "?map=#{name}"

  mapClick: (e) ->
    id = $(e.target).data('id')
    @setState selectedMap: _.where(@state.maps, {_id: id})?[0]

  renderMaps: ->
    return unless (maps = @state?.maps)
    if maps
      <ul className="maps">
        {
          for map in maps
            cx = "map"
            cx += " active" if @state.selectedMap?._id is map._id

            <li onClick={@mapClick} key={map._id} data-id={map._id} className={cx}>
              { map.name }
            </li>
        }
      </ul>
  renderContent: ->
    <div className='form'>
      { @renderMaps() }
      <div className="controls">
        <button className="cancel" onClick={@cancel}> Cancel </button>
        <button className="submit" onClick={@submit}> Open </button>
      </div>
    </div>
