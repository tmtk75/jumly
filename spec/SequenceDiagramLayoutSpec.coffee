require "core"
require "jquery.ext"
utils = require "./jasmine-utils"
SequenceDiagramLayout = require "SequenceDiagramLayout"
SequenceDiagram = require "SequenceDiagram"
SequenceObject = require "SequenceObject"
SequenceDiagramBuilder = require "SequenceDiagramBuilder"

describe "SequenceDiagramLayout", ->

  div = utils.div this

  beforeEach ->
    @layout = new SequenceDiagramLayout

  it "has layout", ->
    expect(typeof @layout.layout).toBe "function"
  
  utils.unless_node ->
    it "determines the size", ->
      diag = new SequenceDiagram
      diag.append obj = new SequenceObject "foobar"
      div.append diag
      @layout.layout diag
      expect(diag.width()).toBeGreaterThan 0
      expect(diag.height()).toBeGreaterThan 0

  beforeEach ->
    @builder = new SequenceDiagramBuilder

  describe "found", ->
    utils.unless_node ->

      it "looks centering" #, ->
        #div.append @builder.build "@found 'foundee'"
        #@layout.layout diag = @builder.diagram()
