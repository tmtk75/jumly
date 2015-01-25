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

      it "starts with 0 and a space", ->
        expect(core._normalize "0 a").toEqual id:"0-a", name:"0 a"

      it "starts with 0 and two spaces", ->
        expect(core._normalize "0 a b").toEqual id:"0-a-b", name:"0 a b"

  describe "_to_ref", ->

    describe "string", ->

      it "starts with 0 and hyphens", ->
        expect(core._to_ref "0-a-b").toEqual "_0_a_b"

