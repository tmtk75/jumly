## (c)copyright 2011-2012, Tomotaka Sakuma all rights reserved.
$(document).on "show", ".alert-message", (e)-> setTimeout (-> $(e.target).fadeOut()), 2000
$(document).on "click", ".alert-message .btn.cancel", (e)-> $(this).parents(".alert-message").hide()
$(document).on "click", ".modal .btn.cancel", (e)-> $(this).parents(".modal").modal 'hide'

storage = window.localStorage
storeKey = "TryJUMLY.sequence.jumlipt"
qp = {}
qp[e[0]] = e[1] for e in (e.split("=") for e in location.search.replace(/^\?/, "").split("&"))
initialJumlipt = (if qp.b then Base64.decode qp.b else storage.getItem storeKey) || ""

viewModel =
  targetJumlipt: ko.observable initialJumlipt
  sampleRequired: (model, event)->
    $(".twipsy").remove()
    model.targetJumlipt JUMLY.TryJUMLY.samples[event.target.id]
  tutorialRequired: (model, event)->
    $(".twipsy").remove()
    a = $(event.target)
    model.targetJumlipt JUMLY.TryJUMLY.Tutorial[a.attr("data-step")][a.attr("data-sub")]
  success: ->
    a = $(".alert-message").hide()
    if $(".diagram > *").length > 0
      a.filter(".success").show().trigger "show"
  errorReason: ko.observable {}
  error: (reason)->
    viewModel.errorReason reason
    $(".alert-message").hide().filter(".error").show()
  urlToShare:
    short: ko.observable "..."
    long: ko.observable "..."
  typing:
    delay:5000, stop:(e)->
      storage.setItem storeKey, viewModel.targetJumlipt()
      $("#auto-save-message").fadeIn().trigger "show"
  disqusOpened: ko.observable false
  openDisqus: -> @disqusOpened !@disqusOpened()
  suppressWithBrowser: (->
    b = navigator.userAgent.match /webkit|opera/i
    unsupported:!b, hide:b)()

viewModel.diagram = JUMLY.ko.dependentObservable viewModel.targetJumlipt, 'sequence'

JUMLY.TryJUMLY.Tutorial.bootup viewModel

$ ->
  ko.applyBindings viewModel, $("body")[0]
  
  $("textarea").typing viewModel.typing
  $("#url-to-show").modal(backdrop:"static",keyboard:true).bind "show", ->
    path = "/Share.#{i18n.ext}?b=\#{Base64.encode viewModel.targetJumlipt()}"
    longUrl = "\#{location.origin}\#{path}"
    viewModel.urlToShare.long longUrl
    JUMLY.TryJUMLY.bitly longUrl, (res)->
      console.error "bit.ly returns something wrong.", res if res.errorCode
      viewModel.urlToShare.short res.results[longUrl].shortUrl

  JUMLY.TryJUMLY.Tutorial.start viewModel, qp.b

