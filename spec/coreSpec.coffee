require "node-jquery"
core = require "core"

describe "core", ->

  describe "exports", ->

  describe "require", ->

    it "should return what to be exported", ->
      class Foo
      core.exports Foo
      foo = core.require "Foo"
      expect(foo).toBe Foo
