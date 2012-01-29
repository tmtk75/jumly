## /TryJUMLY's sample data
JUMLY.TryJUMLY =
  bitly: (args)->
    bitly = "http://api.bit.ly/shorten?version=2.0.1&login=tmtk75&apiKey=R_39bc09b13aac4481bc526f946f7d1538&longUrl=#{encodeURIComponent args.url}&callback=?"
    $.getJSON bitly, (res)-> if res.errorCode then args.failure(res) else args.success(res)
  samples:
    "sample-1":"""
      ## A basic sample
      @found "You", ->
        @message "use", "JUMLY", ->
          @create "Diagram"
      """
    "sample-2":"""
      @found "You", ->
        @message "use", "JUMLY"
        @message "write", "JUMLY", ->
          @create "Diagram"
          @reply "", "You"
      you.iconify "actor"
      diagram.iconify "entity"
      jumly.iconify "controller"
      
      @after (e, d)->
        d.find(".occurrence:eq(1)")
         .twipsy("includes&nbsp;some&nbsp;" +
                 "JavaScript&nbsp;files", "right")
      """ 
    "sample-3":"""
      @found "You", ->
        @message "open", "Front Cover"
        @loop ->
          @alt
            "[page > 0]": -> @message "flip", "Page"
            "[page = 0]": -> @message "stop reading"
          @message "read", "Page"
        @message "close", "Front Cover"
        @ref "Tidy up book at shelf"
      
      @after (e, diag)->
        page.attr(title:"Bootstrap Tooltip")
            .twipsy(placement:"right",trigger:'manual')
            .twipsy('show')
        tiptext = '''
          Tooltip is better<br/>
          when note is exaggerated'''
        diag.find(".occurrence:eq(5)")
            .attr(title:tiptext)
            .twipsy(html:true)
            .twipsy(trigger:'manual',placement:"right")
            .twipsy('show')
      """
    "sample-4":"""
      @found "You", ->
        @create "Diagram"
        @message "show URL", "JUMLY", ->
          @message "generate short URL", "bit.ly", ->
            @reply "", "JUMLY"
          @message "show&nbsp;the URL", ->
          @reply "", "You"
        @message "copy it"
        @ref "Easy Draw, Easy Share!!!"
      ref = @diagram.find(".ref .name")
      ref.css "font-weight":"bold", "font-size":"large"
      """
    "sample-5":"""
      @found "you", ->
        @message "Login", "Gmail", ->
        @create "sign-up", "Facebook account", ->
      
      gmail_logo = '<img src="http://www.sizlotech.com/wp-content/uploads/2011/11/Super_Gmail_Logo1-625x462.png" width="44"/>'
      fb_logo = '<img src="http://burberry-tiepin.x0.com/wp-content/uploads/2012/01/facebook300x300.png" width="44"/>'
      
      you.iconify "actor"
      @diagram.find(".object .name").css(border:"none", "background":"none", "box-shadow":"none")
      gmail.find(".name").append("<br>"+gmail_logo)
      facebook_account.find(".name").append(fb_logo)
      
      @diagram.append $("<div>").css(position:"absolute",right:0,top:0,width:"44%",border:"solid 1px rgba(0,32,64,.2)","border-radius":"3px",padding:"4px 0.5em 4px 1em",background:"rgba(0,32,80,0.4)",color:"white","box-shadow":"2px 1px 2px 1px gray").html "You can append anything and customize looks using CSS/jQuery syntax you are familiar with whenever you want."
      """

COOKEY = "JUMLY.Tutorial.step"
Tutorial =
  bootup: (viewModel)->
    step0n = [null]
    step1n = [null, null, 0, 1, 2, 3, 3]  ## Number is key of data used in tutorial.
    step2n = [null, 0, 1, 2, 3, 3]
    step3n = [0]
    stepn = step0n.length + step1n.length + step2n.length + step3n.length - 1
    stepInCookie = $.cookie COOKEY
    step = ko.observable (if (stepInCookie is undefined or stepInCookie is null) then -1 else parseInt stepInCookie)
    save = (n)->
      step n
      $.cookie COOKEY, n
    tutorial =
      enable: ->
        tutorial.resume()
        tutorial.reset()
      resume: ->
        $("#tutorial, .instructions").show()
      reset: ->
        save 0
        viewModel.targetJumlipt ""
      toNext: ->
        n = step()
        save n + 1 if n < stepn
      toPrev: ->
        return if step() > stepn
        n = step()
        save n - 1 if n > 0
      share: -> save stepn + 1 if step() is stepn
      finish: ->
        save stepn + 2
        $("html").removeClass("tutorial").removeClass tutorial.currentTutorialClass
      hasShared: -> step() is stepn + 1
      hasFinished: -> step() >= stepn + 1
      isNotRun: $.cookie COOKEY
    tutorial.finish() if tutorial.hasShared()
    tutorial.resume() if 0 <= step() <= stepn

    range = (prev, numOfStep)-> if typeof prev is "number" then [prev, prev + numOfStep - 1] else range prev[1] + 1, numOfStep
    prev = 0
    steps = (prev = (range prev, n) for n in [step0n, step1n, step2n, step3n].map (n)-> n.length)

    stepHandlers =
      1: (n)-> viewModel.targetJumlipt (Tutorial.data1[step1n[n]] || "")
      2: (n)-> viewModel.targetJumlipt (Tutorial.data2[step2n[n]] || "")
      3: (n)-> viewModel.targetJumlipt (Tutorial.data3[step3n[n]] || "")
    tutorial.chap = ko.dependentObservable ->
      n = step()
      isIn = (r, v)-> r[0] <= v <= r[1]
      m = ((isIn r, n) for r in steps).indexOf true
    tutorial.sec = ko.dependentObservable ->
      s = step() - steps[tutorial.chap()]?[0]
    tutorial.isIn = (m, n)-> @chap() is m and @sec() is n
    tutorial.hasStarted = ko.dependentObservable -> step() >= 0
    ko.dependentObservable ->
      m = tutorial.chap()
      return unless steps[m]
      s = tutorial.sec()
      $("html").attr("class", "").addClass("tutorial").addClass(tutorial.currentTutorialClass = "tutorial-#{m}-#{s}")
      stepHandlers[m]? s, steps[m][0], steps[m][1]
    
    viewModel.tutorial = tutorial
    viewModel.askTutorial = -> Tutorial.askTutorialToStart()

    jwerty.key '↑', -> tutorial.toPrev()
    jwerty.key '↓', -> tutorial.toNext()
    #jwerty.key '←', -> $("#tutorial").animate right:-2
    #jwerty.key '→', -> $("#tutorial").animate right:-$("#tutorial").width()
    #jwerty.key('⌃+⇧+P/⌘+⇧+P', -> console.log "alsjdf");
    #jwerty.key('↑,↑,↓,↓,←,→,←,→,b,a,↩', -> console.log "KONAMI")

  askTutorialToStart: -> $("#tutorial-ask").show()
  start: (viewModel, jumlipt)->
    unless ($.cookie COOKEY) or jumlipt
      @askTutorialToStart()
    
  data1:
    0:'''
      @found "WebBrowser"'''
    1:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp"'''
    2:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp", ->
          @message "Authenticate&nbsp;credential", ->
            @message "Connect", "DB", ->'''
    3:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp", ->
          @message "Authenticate&nbsp;credential", ->
            @message "Connect", "DB", ->
        @message "GET", "WebApp"'''
  data2:
    0:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp", ->'''
    1:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp", ->
      @before (e, d)->
        d.css "font-weight":"bold"'''
    2:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp"
      @before (e, d)->
        d.find("*").css("box-shadow":"none").end()
         .find(".object .name")
         .css("background":"none",border:"none")'''
    3:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp"
      @before (e, d)->
        d.css("border":"2px dashed #0080c0","padding":"1em 0 1em 0","border-radius":"4px","background-color":"rgba(0,128,192,0.4)")'''
  data3:
    0:'''
      @found "WebBrowser", ->
        @message "POST", "WebApp", ->
          @message "Authenticate&nbsp;credential", ->
            @message "Connect", "DB", ->
        @message "GET", "WebApp"
      @before (e, d)->
        d.find(".object .name")
         .css("font-weight":"bold"
             ,"color":"rgba(0,108,160,1)"
             ,"background-color":"rgba(0,128,192,0.5)"
             ,"border-color":"rgba(0,128,192,0.8)")'''
             
JUMLY.TryJUMLY.Tutorial = Tutorial
$ ->
  $("*[rel=twipsy]").twipsy(trigger:'manual',html:true).twipsy('show')
