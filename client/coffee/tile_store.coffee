# { 'add', x, y, index, layer }
# { 'remove', x, y, previous, layer }
# { 'change', x, y, index, previous, layer }

class TileStore
  constructor: ->

    @_queue = []

  push: (data) =>
    {type, x, y, index, layer} = data

    return unless x? and y? and index? and layer?
    return unless type and type in ['add', 'remove']

    @_queue.push data

  shift: =>
    @_queue.shift()

  inverse: (e) ->
    inverse = {x: e.x, y: e.y, layer: e.layer}
    switch e.type
      when 'add'
        _.extend inverse, {type: 'remove'}
      when 'remove'
        _.extend inverse, {type: 'add', index: e.previous}
      when 'change'
        _.extend inverse, {type: 'change', index: e.previous, previous: e.index}

module.exports = new TileStore()
