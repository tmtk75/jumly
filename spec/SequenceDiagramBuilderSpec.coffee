SequenceDiagramBuilder = require "SequenceDiagramBuilder"

describe "SequenceDiagramBuilder", ->

  beforeEach ->
    @builder = new SequenceDiagramBuilder

  describe "diagram", ->

    it "returns diagram", ->
      expect(@builder.diagram().hasClass "diagram").toBeTruthy()
  
  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node.hasClass "diagram").toBeTruthy()
    
  describe "found", ->

    it "returns itself", ->
      b = @builder.found "foo"
      expect(b).toBe @builder
      
