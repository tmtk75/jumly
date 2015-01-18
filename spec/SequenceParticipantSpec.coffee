core = require "core.coffee"
_u = require "jquery.ext.coffee"
utils = require "./jasmine-utils.coffee"
SequenceDiagramLayout = require "SequenceDiagramLayout.coffee"
SequenceDiagramBuilder = require "SequenceDiagramBuilder.coffee"

describe "SequenceParticipant", ->

  div = utils.div this

  beforeEach ->
    @layout = new SequenceDiagramLayout
    @builder = new SequenceDiagramBuilder

  describe "one participant", ->
    beforeEach ->
      @diagram = @builder.build """
        @found "a"
        """
      div.append @diagram
      @layout.layout @diagram

    it "is calculated for width", ->
      p = @diagram.find(".participant:eq(0)")
      expect(p.outerWidth()).toBe 2 + 0 + 4 + 88 + 4 + 0 + 2

    it "is calculated for height", ->
      p = @diagram.find(".participant:eq(0)")
      n = p.find(".name")
      # 1.2 is from https://developer.mozilla.org/en-US/docs/Web/CSS/line-height
      lh = Math.round(parseInt(n.css("font-size")) * 1.2) # estimated line-height

      expect(p.outerHeight()).toBe 2 + 8 + 0 + lh + 0 + 8 + 2

  describe "two participants", ->
    beforeEach ->
      @diagram = @builder.build """
        @found "0123456789abcdef0123456789abcdef", ->
          @message "hi", "You"
        """
      div.append @diagram
      @layout.layout @diagram

    it "is aligned at bottom", ->
      p0 = @diagram.find(".participant:eq(0)")
      p1 = @diagram.find(".participant:eq(1)")

      expect(utils.bottom p0).toBe utils.bottom p1
