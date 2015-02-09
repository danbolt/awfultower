em = require '../event_manager'

module.exports = React.createClass
  getInitialState: ->
    mode: "square"
    gridOn: true

  brushClick: (e) ->
    return unless (type = $(e.target).closest("li").data("value"))
    em.call em.types.brushChanged, [type]

    @setState mode: type

  renderBrush: ->
    iconClass = switch @state.mode
      when "square"
        "fa-square"
      when "horizontal"
        "fa-minus"
      when "vertical"
        "fa-minus fa-rotate-90"

    <li className="active">
      Brush:
      <i className="fa #{iconClass}" />
      <ul className="dropdown-list">
        <li data-value="square" onClick={@brushClick}>
           <i className="fa fa-square" /> Square
        </li>
        <li data-value="horizontal" onClick={@brushClick}>
           <i className="fa fa-minus" /> Horizontal
        </li>
        <li data-value="vertical" onClick={@brushClick}>
           <i className="fa fa-minus fa-rotate-90" /> Vertical
        </li>
      </ul>
    </li>

  toggleGrid: ->
    gridOn = not @state.gridOn
    @setState gridOn: gridOn

    em.call em.types.toggleGrid, [gridOn]

  renderGrid: ->
    cx = "fa fa-th"
    cx += " active" if @state.gridOn
    <li className="active control" onClick={@toggleGrid}>
      <i className={cx} />
    </li>

  render: ->
    <div id="header" className="navbar" data-ks-navbar>
      <nav>
        <ul>
          <li>
            <span className="logo">LAAS</span>
          </li>
          { @renderBrush() }
          { @renderGrid() }
        </ul>
      </nav>
    </div>
