JUMLY.TryJUMLY.utils =
  queryparams:->
    qp = {}
    qp[e[0]] = e[1] for e in (e.split("=") for e in location.search.replace(/^\?/, "").split("&"))
    qp
