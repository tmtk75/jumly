jumly = $.jumly

## Deprecated.
jumly.identify = (e)->
  unless e then return null
  if (p for p of e).length is 1 and p is "id"
    switch typeof e.id
      when "number", "string" then e.id
      when "function" then e.id()
      else return null
## Deprecated.
jumly.normalize = (a, b) ->
  return a if a is undefined or a is null
  switch typeof a
    when "string" then return $.extend name:a, b
    when "boolean", "number" then return null
  return null if $.isArray a
  return a if a.hasOwnProperty "id"
  r = {}
  for key, val of a
    if typeof key is "string" and key.match(/[1-9][0-9]*/) and typeof val is "string"
      r.id = parseInt key
      r.name = val
    else
      r[key] = val
  if r.hasOwnProperty "name"
    r
  else
    r.name = key
    attrs = r[key]
    delete r[key]
    $.extend r, attrs
## Deprecated
jumly.lang =
  _gives: (a, dic)->
    gives = (query)->
          r = dic[query]
          if r then r else null
    if !a.gives then return gives
    f = a.gives
    (query)->
      r = f(query)
      if r.length > 0 or r.of or r.as
          return r
      gives(query)
  _as: (m)-> as:(e)-> m[e]
  _of: (nodes, query)->
    (unode)->
      n = nodes.filter (i, e)->
        e = jumly(e)[0]
        s = e.gives(unode.data("uml:property").type)
        if s is unode then e else null
      if n.length > 0 then jumly(n)[0] else []

