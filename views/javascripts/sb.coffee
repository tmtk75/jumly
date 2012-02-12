    $.jumly.preferences(".sequence-diagram").compose_span = 24
    $.jumly.preferences(".sequence-diagram").compose_most_left = 0
    
    notify = (type, message, duration = 1500) ->
        msg = $("<div>").addClass("alert-message").addClass(type).text(message)
        $("#alert-message-placeholder").hide().html(msg).fadeIn("fast")
        setTimeout (-> msg.fadeOut("slow", -> msg.remove())), duration
    
    f = (suppress = false) ->
        try
            script = $("<script>").attr(type:"text/jumly+sequence", "target-id":"preview-for-sequence-placeholder")
                                  .text $("#dsl").attr("value")
            JUMLY.evalHTMLScriptElement script
        catch ex
            notify "error", ex.message, 4000
    
    g = ->
        $("#custom-style").html $("#css").attr("value")
        $(".diagram").data("uml:this").compose()
    $("#dsl").focus().typing delay:400, stop:f
    $("#css").focus().typing delay:400, stop:g
    
    templid = 0
    templs = (k) ->
        templid += 1
        switch k
            when "@found"   then "@found 'obj-#{templid}', ->"
            when "@message" then "  @message 'new message', 'obj-#{templid}', ->"
            when "@create"  then "  @create 'obj-#{templid}', ->"
            when "@destroy" then "  @destroy"
            when "@reply"   then "    @reply '', 'Coworker'"
            when "@ref"     then "  @ref 'another sequence'"
            when "@lost"    then "  @lost"
            when "@loop"    then "  @loop ->\n    @message 'do somehting'"
            when "@alt"     then "  @alt {\n    '[x>0]':-> @message 'start', 'A',\n    '[x<0]':-> @message 'end', 'A'\n  }"
            when "@reactivate" then
    
    init = ->
        _add = (k) ->
            v = $("#dsl").attr("value")
            $("#dsl").attr("value", v + "\n" + templs k)
            f()
        $("#buttons input").addClass("btn").addClass("small").click -> _add $(this).attr("value")
    
    $ ->
        f true
        g true
        init()

