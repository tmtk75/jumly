## /TryJUMLY's sample data
JUMLY.TryJUMLY =
  bitly: Bitly.shorten

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
        viewModel.jumly.jumlipt ""
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
    $("#btnToShowUrl").on "click", tutorial.share ## Go step
    tutorial.finish() if tutorial.hasShared()
    tutorial.resume() if 0 <= step() <= stepn

    range = (prev, numOfStep)-> if typeof prev is "number" then [prev, prev + numOfStep - 1] else range prev[1] + 1, numOfStep
    prev = 0
    steps = (prev = (range prev, n) for n in [step0n, step1n, step2n, step3n].map (n)-> n.length)

    stepHandlers =
      1: (n)-> viewModel.jumly.jumlipt (Tutorial.data1[step1n[n]] || "")
      2: (n)-> viewModel.jumly.jumlipt (Tutorial.data2[step2n[n]] || "")
      3: (n)-> viewModel.jumly.jumlipt (Tutorial.data3[step3n[n]] || "")
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
console.log "Try JUMLY tutorial successfully loaded."
