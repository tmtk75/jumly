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

  describe "_normalize", ->
  
    describe "string", ->

      it "returns object has id and name", ->
        e = core._normalize "foo"
        expect(e).toEqual id:"foo", name:"foo"


  describe "JUMLY", ->
    
    it "is root object"
    
    it "should be loaded by core", ->
      expect(JUMLY).not.toBeUndefined()

    describe "env", ->
      env = JUMLY.env
      
      it "should show whether it is node or browser", ->
        if typeof module is 'undefined'
          expect(env.is_node).toBe false
        else
          expect(env.is_node).toBe true

