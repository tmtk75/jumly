SequenceDiagramBuilder = require "SequenceDiagramBuilder"

describe "SequenceDiagramBuilder", ->

  describe "build", ->

    beforeEach ->
      @builder = new SequenceDiagramBuilder

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node.hasClass "diagram").toBe true
