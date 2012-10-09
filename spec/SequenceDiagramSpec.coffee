describe "SequenceDiagram", ->
  SequenceDiagram = require "SequenceDiagram"

  beforeEach ->
    @diagram = new SequenceDiagram "hello"
    @addMatchers
      haveClass: (expected)->
        @actual.hasClass expected

  describe "SequenceObject", ->
    SequenceObject = require "SequenceObject"
    beforeEach ->
      @object = new SequenceObject "user"
    
    it "has .object", ->
      expect(@object).haveClass "object"
      
    it "has name", ->
      expect(@object.find(".name").text()).toBe "user"
