jumlyBind =
  init: (elem, val, bindings, model)->
  update: (elem, val, bindings, model)->
    koarg = element:elem, valueAccessor:val, allBindingsAccessor:bindings, viewModel:model
    diag = ko.utils.unwrapObservable val()
    try
      $(elem).html diag
      throw diag unless diag.compose?
      diag.compose()
      bindings().success? {diagram:diag, ko:koarg}
    catch ex
      bindings().error? ($.extend ex, {type:ex.constructor.name, diagram:diag, ko:koarg})

name2builder =
  sequence: "SequenceDiagramBuilder"

ko =
  ## observableJumlipt: string wrapped with ko.observable.
  ## builder: DiagramBuilder or string.
  dependentObservable: (observableJumlipt, builder)->
    unless ko.isObservable observableJumlipt
      throw new JUMLY.Error "not_observable", "is not observable", [observableJumlipt]
    builder = name2builder[builder.toLowerCase()] if typeof builder is "string"
    ko.dependentObservable ->
      try
        (new builder).build observableJumlipt()
      catch ex
        ex

$ ->
  if window.ko
    ko.bindingHandlers.jumly = jumlyBind
