## (c)copyright 2011-2012, Tomotaka Sakuma all rights reserved.
_requireSample = (model, event)->
  $(".twipsy").remove()
  model.targetJumlipt JUMLY.TryJUMLY.samples[event.target.id]
    
_requireTutorialData = (model, event)->
  $(".twipsy").remove()
  a = $(event.target)
  model.targetJumlipt JUMLY.TryJUMLY.Tutorial[a.attr("data-step")][a.attr("data-sub")]

_success = ->
  a = $(".alert-message").hide()
  if $(".diagram > *").length > 0
    a.filter(".success").show().trigger "show"

_error = (reason)->
  viewModel.errorReason reason
  $(".alert-message").hide().filter(".error").show()

storage = new JUMLY.LocalStorage ["jumlipt"]

_stop = (e)->
  storage.jumlipt viewModel.targetJumlipt()
  $("#auto-save-message").fadeIn().trigger "show"

_openDisqus = -> @disqusOpened !@disqusOpened()

qp = JUMLY.TryJUMLY.utils.queryparams()
viewModel =
  targetJumlipt: ko.observable ((if qp.b then Base64.decode qp.b else storage.jumlipt()) || "")  # Initial JUMIPT value
  errorReason: ko.observable {}
  urlToShare: {short:(ko.observable "..."), long:(ko.observable "...")}
  disqusOpened: ko.observable false

  sampleRequired: _requireSample
  tutorialRequired: _requireTutorialData 
  success: _success 
  error: _error
  openDisqus: _openDisqus
  suppressWithBrowser: (-> b = navigator.userAgent.match /webkit|opera/i; unsupported:!b, hide:b)()

viewModel.diagram = JUMLY.ko.dependentObservable viewModel.targetJumlipt, 'sequence'

JUMLY.TryJUMLY.Tutorial.bootup viewModel

$(document).on "show", ".alert-message", (e)-> setTimeout (-> $(e.target).fadeOut()), 2000
$(document).on "click", ".alert-message .btn.cancel", (e)-> $(this).parents(".alert-message").hide()
$(document).on "click", ".modal .btn.cancel", (e)-> $(this).parents(".modal").modal 'hide'

$("#url-to-show")
  .modal(backdrop:"static",keyboard:true)
  .bind "show", ->
    path = "/Share.#{JUMLY.TryJUMLY.lang}?b=#{Base64.encode viewModel.targetJumlipt()}"
    longUrl = "#{location.origin}#{path}"
    viewModel.urlToShare.long longUrl
    JUMLY.TryJUMLY.bitly
      url:longUrl
      success:(res)-> viewModel.urlToShare.short res.results[longUrl].shortUrl
      failure:(res)-> console.error "bit.ly returns something wrong.", res

$("textarea").typing {delay:5000, stop:_stop}

$ ->
  ko.applyBindings viewModel, $("body")[0]
  JUMLY.TryJUMLY.Tutorial.start viewModel, qp.b
