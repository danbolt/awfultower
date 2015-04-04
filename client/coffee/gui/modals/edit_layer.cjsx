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
    properties: _.clone(@props.layer.properties) or []

  nameChange: (e) ->
    @setState name: e.target.value

  delete: (e) ->
    ServerAgent.send 'remove_layer', {layerId: @props.layer.id}
    @close()
    e.preventDefault()


  getProperties: ->
    properties = $(".property")

    props = []

    _.each properties, (prop) ->
      $prop = $(prop)
      key = $prop.find(".key").get(0).value
      value = $prop.find(".value").get(0).value

      if key and value
        props.push {key: key, value: value}

    props

  submit: (e) ->
    e.preventDefault()

    properties = @getProperties()

    if @state.name isnt @props.layer.name
      ServerAgent.send 'rename_layer',
        { layerId: @props.layer.id, name: @state.name }

    if not _.isEqual(properties, @props.layer.properties)
      ServerAgent.send 'change_layer_properties',
        { layerId: @props.layer.id, properties: properties }

  removeProperty: (index, e) ->
    properties = @state.properties
    properties.splice(index, 1)
    @setState properties: properties
    e.preventDefault()

  renderProperties: ->
    for property, n in @state.properties
      <div className="property" key={property.key}>
        <input type="text" className="key" defaultValue={property.key} />
        <input type="text" className="value" defaultValue={property.value} />
        <button className="fa fa-times" onClick={_.partial @removeProperty, n, _ } />
      </div>

  newPropertyClick: (e) ->
    properties = @state.properties
    properties.push {key: "value#{properties.length}", value:""}
    @setState properties: properties

    e.preventDefault()

  renderContent: ->
    <div>
      <form className="form">

        <fieldset>
          <label> Name </label>
          <input type="text" onClick={@nameChange} valueLink={@linkState('name')} />
        </fieldset>

        <fieldset>
          <label> Properties </label>
          { @renderProperties() }

          <button className="newProperty" onClick={@newPropertyClick}>
            new property
          </button>

        </fieldset>

        <button className="delete" onClick={@delete}> Delete Layer </button>

        <div className="controls">
          <button className="cancel" onClick={@cancel}> Cancel </button>
          <button className="submit" onClick={@submit}> Save </button>
        </div>

      </form>
    </div>
