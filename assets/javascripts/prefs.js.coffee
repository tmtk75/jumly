class JUMLYPreferences
  @put = (a, b)-> JUMLYPreferences.values[a] = b
  @get = (a)->
    e = JUMLYPreferences.values[a]
    if typeof e is "function"
      e()
    else
      e

JUMLY.Preferences = (a)->
  if typeof a is "string"
    JUMLYPreferences.get a
  else
    k = (e for e of a)[0]
    JUMLYPreferences.put k, a[k]


JUMLYPreferences.values =
  "document.id.validation.enable": false
