self = require: unless typeof require is "undefined" then require else JUMLY.require

self.require "node-jquery-xhr"
core = self.require "core"

describe "core", ->

  describe "exports", ->

  describe "require", ->

    it "should return what to be exported", ->
      if !core.env.is_node
        class Foo
        core.exports Foo
        foo = self.require "Foo"
        expect(foo).toBe Foo

  describe "_normalize", ->
  
    describe "string", ->

      it "returns object has id and name", ->
        expect(core._normalize "foo").toEqual id:"foo", name:"foo"
      
      it "pyphenates unacceptable characters to '-' for id", ->
        expect(core._normalize "a 1").toEqual id:"a-1", name:"a 1"
        expect(core._normalize "a-1").toEqual id:"a-1", name:"a-1"
        expect(core._normalize "a_1").toEqual id:"a_1", name:"a_1"
  
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

