JUMLY.knockout = ->
  ko.bindingHandlers.jumly =
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
        
