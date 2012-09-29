HTMLElement = require "HTMLElement"

class Diagram extends HTMLElement
  ## v0.1.1 Tenatative Implementation.
  @isIDExisting = (id, diag)->
    if Preferences "document.id.validation.enable"
      $("##{id}").length > 0
    else
      false

Diagram::_build_ = (div)-> div.addClass "diagram"
    
Diagram::_def_ = (varname, e)-> eval "#{varname} = e"
    
Diagram::_regByRef_ = (id, obj)->
  ref = Naming.toRef id
  throw new Error("Already exists for '#{ref}' in the " + $.kindof(this)) if this[ref]
  throw new Error("Element which has same ID(#{id}) already exists in the document.") if Diagram.isIDExisting? id, this 
  this[ref] = obj
  ref


core = require "core"
if core.env.is_node
  module.exports = Diagram
else
  core.exports Diagram
