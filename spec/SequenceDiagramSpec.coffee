describe "SequenceDiagram", ->
  SequenceDiagram = require "SequenceDiagram"

  beforeEach ->
    @diagram = new SequenceDiagram "hello"

  describe "SequenceObject", ->
    SequenceObject = require "SequenceObject"
    
    it "has name", ->
      obj = new SequenceObject "user"
      expect(obj.find(".name").text()).toBe "user"
    
      
