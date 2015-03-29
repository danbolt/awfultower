module.exports =

  close: ->
    @props.flux.actions.closeModal()

  render: ->
    return unless @config

    cx = "modal"
    cx += " #{@config.className}" if @config.className

    <div className={cx}>
      <div className="header">
        <h2 className="title">{ @config.title }</h2>
        <button className="close fa fa-times" onClick={@close} />
      </div>
      <div className="content">
        { @renderContent() }
      </div>
    </div>
