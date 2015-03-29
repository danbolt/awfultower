Stamp = require '../editor/lib/stamp'

{tileWidth, tileHeight, sign} = require '../editor/utils'

module.exports = React.createClass
  displayName: "QuickSelect"

  mixins: [Fluxxor.FluxMixin(React), Fluxxor.StoreWatchMixin("QuickSelectStore")]

  getStateFromFlux: ->
    @getFlux().store("QuickSelectStore").getState()

  getInitialState: -> {}

  componentDidMount: ->
    $(window).keydown (e) =>
      return if @getFlux().stores.ModalStore.open
      if 48 <= e.keyCode <= 57
        Stamp.setSingle @state.quickSelectIndicies[e.keyCode-48]

  render: ->
    return <div /> unless @state.quickSelectIndicies

    style =
      width: "#{tileWidth}px"
      height: "#{tileHeight}px"
      background: "url('images/level3.png')"

    <div id="quick-select" style={height: "#{tileHeight}px"}>
      {
        for index, i in @state.quickSelectIndicies
          st = _.clone style
          # Figure out the tile index based on x, y coords
          x = (index % 8) * tileWidth
          y = Math.floor(index / 8) * tileHeight
          st['background-position'] = "-#{x}px -#{y}px" if index?
          st.background = null unless index?

          <div style={st} onClick={_.partial Stamp.setSingle, index} key={i}/>
      }

    </div>
