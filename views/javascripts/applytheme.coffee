@found "Browser", ->
  @message "request", "Proxy", ->
    @message "send HTTP request", "Web Server", ->
      @message "dispatch", "Servlet Container", ->
        @message "check context path"
        @create  "HTTP Session"
        @message "put username", "HTTP Session"
        @message "select", "Database"
        @message "build JSON", -> #@note "This is an typical HTTP server like apache", left:30, top:40
        @reply "JSON", "Browser"
      #@note "This JSON includes username, user-ID, TEL, e-mail address <a href='http://www.yahoo.co.jp'>yahoo</a>"
  @message "format"
  @beforeCompose (e, diag) ->
    #diag.Database.note "MySQL, H2, Oracle, ...", left:-158, top:60, width:120, "min-height":50
    diag.iconify = (a) ->
      for e of a
        this[e].iconify a[e]
    diag.iconify
      "Browser"          :"view"
      "Proxy"            :"controller"
      "Web Server"       :"controller"
      "Servlet Container":"controller"
      "HTTP Session"     :"entity"
      "Database"         :"entity"
    diag.find(".note:eq(0)").addClass("piled-note")
    diag.find(".note:eq(1)").addClass("folded-note")
    diag.find(".note:eq(2)").addClass("plain-note")
    $("html").addClass $.client.os
    diag.addClass("theme-monotone")
  @afterCompose (e, diag) ->
    $.jumly.centeringToParent $(".message .name", diag)

