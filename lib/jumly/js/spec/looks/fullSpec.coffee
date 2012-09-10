describe "", ->
  s = """
@found "User", ->
  @message "search", "Browser", ->
    @message "http request", "HTTP Server", ->
      @create "HTTP Session"
      @message "save state", "HTTP Session"
      @message "do something"
      @message "query", "Database", ->
      @reply "", "Browser"
    @loop @message "request resources", "HTTP Server", ->
      @alt {
        "[found]": -> @message "update", "Database"
        "[missing]": -> @message "scratch", "HTTP Session"
      }
    @ref "Rendering page"
    @reactivate "disconnect", "HTTP Server", ->
      @destroy "HTTP Session"

  @before (e, d) ->
    d.user.iconify "actor"
    d.browser.iconify "view"
    d["http_session"].iconify "controller"
    d["http_server"].iconify "controller"
    d.database.iconify("entity").css("margin-left":-80)
    d["http_session"].lost()
  
  @after (e, diag)->
    f = (e)-> $(e.currentTarget).addClass "focused-hovered"
    g = (e)-> $(e.currentTarget).removeClass "focused-hovered"
    $(".object .name, .message .name").hover f, g
  """
  it "should be", ->
    diag = (new JUMLY.SequenceDiagramBuilder).build s
    $("body").append diag
    diag.compose()
