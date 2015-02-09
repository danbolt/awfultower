class EventManager
  constructor: ->
    @events = {}
    @types =
      brushChanged: "brush-changed"
      toggleGrid: "toggle-grid"

  register: (type, callback) ->
    @events[type] ||= []
    @events[type].push callback

  call: (type, data) ->
    return console.log "Event type #{type} not defined" if not type

    if (callbacks = @events[type])
      callback(data...) for callback in callbacks

module.exports = new EventManager()
