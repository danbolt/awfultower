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

  mapClick: (e) ->
    name = $(e.target).data('name')
    window.location = "?map=#{name}"

  renderMaps: ->
    return unless (maps = @state?.maps)
    if maps
      <ul className="maps">
        {
          for map in maps
            <li onClick={@mapClick} key={map.id} data-name={map.name}>
              { map.name }
            </li>
        }
      </ul>
  renderContent: ->
    <div className='form'>
      { @renderMaps() }
      <div className="controls">
        <button className="cancel" onClick={@cancel}> Cancel </button>
        <button className="submit" onClick={@submit}> Create </button>
      </div>
    </div>
