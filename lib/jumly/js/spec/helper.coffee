is_running_on_ = (expr)-> ->
  try eval(expr); true; catch ex
    false
is_running_on_browser = is_running_on_ "window"
is_running_on_nodejs  = is_running_on_ "global"

if is_running_on_nodejs()
  console.log "running on Node.js"

if is_running_on_browser()
  console.log "running on browser"
  window.global = window
  window.require = (a)->
    console.log a
    if a.match(/jumly$/)
      JUMLY:JUMLY
