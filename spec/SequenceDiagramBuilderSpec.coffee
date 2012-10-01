SequenceDiagramBuilder = require "SequenceDiagramBuilder"

describe "SequenceDiagramBuilder", ->

  beforeEach ->
    @builder = new SequenceDiagramBuilder

  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node.hasClass "diagram").toBe true

  describe "found", ->

    it "returns itself", ->
      builder = @builder.found("")
      expect(builder).toBe @builder
