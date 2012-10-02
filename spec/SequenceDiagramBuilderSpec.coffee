SequenceDiagramBuilder = require "SequenceDiagramBuilder"

describe "SequenceDiagramBuilder", ->

  beforeEach ->
    @builder = new SequenceDiagramBuilder
    @builder.diagram = @builder._new_diagram()

  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node.hasClass "diagram").toBeTruthy()

  describe "found", ->

    it "returns itself", ->
      builder = @builder.found "foo"
      foo = builder._find_or_create "foo"

      expect(builder).toBe @builder
      expect(typeof foo.data).toBe 'function'
