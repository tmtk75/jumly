JUMLY = window.JUMLY

class JUMLYDiagram extends JUMLY.HTMLElement
  ## v0.1.1 Tenatative Implementation.
  @isIDExisting = (id, diag)->
    if JUMLY.Preferences "document.id.validation.enable"
      $("##{id}").length > 0
    else
      false
        
JUMLYDiagram::_build_ = (div)-> div.addClass "diagram"
    
JUMLYDiagram::_def_ = (varname, e)-> eval "#{varname} = e"
    
JUMLYDiagram::_regByRef_ = (id, obj)->
  ref = JUMLY.Naming.toRef id
  throw new Error("Already exists for '#{ref}' in the " + $.kindof(this)) if this[ref]
  throw new Error("Element which has same ID(#{id}) already exists in the document.") if JUMLY.Diagram.isIDExisting? id, this 
  this[ref] = obj
  ref

JUMLY.Diagram = JUMLYDiagram


