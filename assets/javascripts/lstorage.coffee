class LocalStorage
  constructor: (props, @prefix = "JUMLY.")->
    this[key] = LocalStorage._spawn_ key for key in props
  @_spawn_ = (name, _kind = "string")->
    (val, kind = _kind)->
      key = "#{@prefix}#{name}"
      s = window.localStorage
      unless val then s.getItem key else s.setItem key, val

JUMLY.LocalStorage = LocalStorage
