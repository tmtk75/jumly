$ = require "jquery"
HTMLElement = require "HTMLElement.coffee"
core = require "core.coffee"

class Diagram extends HTMLElement
  constructor: ->
    super()
    @addClass "diagram"

## Enable var with given name
Diagram::_var = (varname, e)->
  eval "#{varname} = e"

## Enable ref name from id
Diagram::_reg_by_ref = (id, obj)->
  exists = (id, diag)-> $("##{id}").length > 0
  ref = core._to_ref id
  throw new Error("Already exists for '#{ref}'") if this[ref]
  throw new Error("Element which has same ID(#{id}) already exists in the document.") if exists id, this
  this[ref] = obj
  ref


module.exports = Diagram
