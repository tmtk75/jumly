require "node-jquery"
core = require "core"

describe "core", ->

  describe "exports", ->

  describe "require", ->

    it "should return what to be exported", ->
      if !core.env.is_node
        class Foo
        core.exports Foo
        foo = require "Foo"
        expect(foo).toBe Foo
