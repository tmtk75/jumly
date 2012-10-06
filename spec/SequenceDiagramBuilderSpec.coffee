SequenceDiagramBuilder = require "SequenceDiagramBuilder"

describe "SequenceDiagramBuilder", ->

  beforeEach ->
    @builder = new SequenceDiagramBuilder
    @builder._diagram = @builder._new_diagram()

  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node.hasClass "diagram").toBeTruthy()
    
  describe "found", ->

    it "returns itself", ->
      b = @builder.found "foo"
      expect(b).toBe @builder
      
    describe "_find_or_create", ->

      it "returns node having data", ->
        foo = @builder._find_or_create "foo"
        expect(typeof foo.data).toBe 'function'
  
  describe "diagram", ->

    it "returns diagram", ->
      diag = (@builder.found "hello").diagram()
      expect(diag.hasClass "diagram").toBeTruthy()
