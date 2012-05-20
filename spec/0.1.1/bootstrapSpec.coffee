require "node-jquery"
_ = require "underscore"
JUMLY = (require "../jumly").JUMLY

specs = require("fs").readdirSync(__dirname).filter (e)->
  e.match(".*Spec.*") and not(e is "bootstrapSpec.coffee")

#require "./diagramSpec"
_.each specs, (e)-> require "./#{e}"

