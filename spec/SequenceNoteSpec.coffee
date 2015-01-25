core = require "core.coffee"
utils = require "./jasmine-utils.coffee"
SequenceDiagramLayout = require "SequenceDiagramLayout.coffee"
SequenceDiagramBuilder = require "SequenceDiagramBuilder.coffee"

describe "SequenceNote", ->

  div = utils.div this

  beforeEach ->
    @layout = new SequenceDiagramLayout
    @builder = new SequenceDiagramBuilder

  describe "issue#18", ->
    beforeEach ->
      @diagram = @builder.build """
        @found "App User", ->
          @note "Product ID & price"
          @create "A"
        """
      div.append @diagram
      @layout.layout @diagram

    it "is a more than 2px gap between bottom of note and top of participant", ->
      n = @diagram.find(".note:eq(0)")
      p = @diagram.find(".participant:eq(1)")
      expect(utils.top p).toBeGreaterThan (utils.bottom n) + 2
