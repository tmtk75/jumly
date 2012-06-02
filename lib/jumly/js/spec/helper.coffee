window.require = (a)->
  console.log a
  if a.match(/jumly$/)
    JUMLY:JUMLY
