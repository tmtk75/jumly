replaceSmoothly = (that, old, a)->
  a.css visibility:"hidden"
  that.append a
  a.css left:'', top:'', position:''
  a.compose()
  a.hide()
  old.css height:0, padding:0
  a.css visibility:"visible"
  a.fadeIn 'slow'
  old.fadeOut 'slow', -> t.remove()

jQuery.fn.jumlize = (kind, script)->
  builder = 
    sequence: JUMLY.SequenceDiagramBuilder
  diag = (new builder[kind]).build script
  f = (diag)=>
    old = @find "> *"
    replaceSmoothly this, old, diag
  g = (diag)=>
    @find("> *").remove().end().append diag
    diag.compose()
  g diag
