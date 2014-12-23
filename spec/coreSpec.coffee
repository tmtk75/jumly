core = require "core.coffee"

describe "core", ->

  describe "_normalize", ->
  
    describe "string", ->

      it "returns object has id and name", ->
        expect(core._normalize "foo").toEqual id:"foo", name:"foo"
      
      it "pyphenates unacceptable characters to '-' for id", ->
        expect(core._normalize "a 1").toEqual id:"a-1", name:"a 1"
        expect(core._normalize "a-1").toEqual id:"a-1", name:"a-1"
        expect(core._normalize "a_1").toEqual id:"a_1", name:"a_1"
