## (c)copyright 2011-2012, Tomotaka Sakuma all rights reserved.
_requireSample = (model, event)->
  $(".twipsy").remove()
  model.jumly.jumlipt JUMLY.TryJUMLY.samples[event.target.id]
    
_requireTutorialData = (model, event)->
  $(".twipsy").remove()
  a = $(event.target)
  model.jumly.jumlipt JUMLY.TryJUMLY.Tutorial[a.attr("data-step")][a.attr("data-sub")]

_success = ->
  a = $(".alert-message").hide()
  if $(".diagram > *").length > 0
    a.filter(".success").show().trigger "show"

_error = (reason)->
  viewModel.jumly.errorReason reason
  $(".alert-message").hide().filter(".error").show()

storage = new JUMLY.LocalStorage ["jumlipt"]

_toggleDisqus = -> @disqusOpened !@disqusOpened()

givenJumlipt = JUMLY.TryJUMLY.utils.queryparams().b

viewModel =
  urlToShare: {short:(ko.observable "..."), long:(ko.observable "...")}
  disqusOpened: ko.observable false
  cssStylesOfBrowser: ((ua)-> b = ua.match /webkit|opera/i; unsupported:!b, hide:b)(navigator.userAgent) ## Returns object which ko css binding requires.

  want: ## User Needs.
    toCommentOnDisqus: _toggleDisqus
    toRequireSampleJumlipt: _requireSample
    toRequireJumliptOfTutorial: _requireTutorialData

  jumly:
    jumlipt: ko.observable ((if givenJumlipt then Base64.decode givenJumlipt else storage.jumlipt()) || "")  # Initial JUMIPT value
    errorReason: ko.observable {}
    success:_success
    error:_error

viewModel.diagram = JUMLY.ko.dependentObservable viewModel.jumly.jumlipt, 'sequence'

JUMLY.TryJUMLY.Tutorial.bootup viewModel

fillURLtoShare = ->
  path = "/Share.#{JUMLY.TryJUMLY.lang}?b=#{Base64.encode viewModel.jumly.jumlipt()}"
  longUrl = "#{location.origin}#{path}"
  viewModel.urlToShare.long longUrl
  JUMLY.TryJUMLY.bitly
    url:longUrl
    success:(res)-> viewModel.urlToShare.short res.results[longUrl].shortUrl
    failure:(res)-> console.error "bit.ly returns something wrong.", res

$(document).on("show", ".alert-message", (e)-> setTimeout (-> $(e.target).fadeOut()), 2000)
           .on("click", ".alert-message .btn.cancel", (e)-> $(this).parents(".alert-message").hide())
           .on("click", ".modal .btn.cancel", (e)-> $(this).parents(".modal").modal 'hide')
$("#url-to-show").modal(backdrop:"static",keyboard:true)
                 .bind "show", fillURLtoShare
saveAndNotice = (e)->
  storage.jumlipt viewModel.jumly.jumlipt()
  $("#auto-save-message").fadeIn().trigger "show"
$("textarea").typing delay:5000, stop:saveAndNotice

$ ->
  ko.applyBindings viewModel, $("body")[0]
  JUMLY.TryJUMLY.Tutorial.start viewModel, givenJumlipt
