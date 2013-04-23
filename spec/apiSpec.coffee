self = require: unless typeof require is "undefined" then require else JUMLY.require

self.require "node-jquery"
core = self.require "core"
self.require "api"

describe "JUMLY", ->

  describe "scan", ->
    it "should take jQuery nodeset at 1st arg", ->
      nodes = $ """
                <div data-jumly=""></div>
                """
      expect(JUMLY.scan nodes).toBeDefined()
