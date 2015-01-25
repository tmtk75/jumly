utils = require "./jasmine-utils.coffee"
SequenceDiagram = require "SequenceDiagram.coffee"
SequenceParticipant = require "SequenceParticipant.coffee"
SequenceOccurrence = require "SequenceOccurrence.coffee"
SequenceFragment = require "SequenceFragment.coffee"
SequenceRef = require "SequenceRef.coffee"
SequenceDiagramBuilder = require "SequenceDiagramBuilder.coffee"
SequenceDiagramLayout = require "SequenceDiagramLayout.coffee"

describe "SequenceDiagram", ->
  div = utils.div this

  beforeEach ->
    @layout = new SequenceDiagramLayout
    @builder = new SequenceDiagramBuilder
    utils.matchers this
    @diagram = new SequenceDiagram "hello"

  it "has .diagram and .sequence-diagram", ->
    expect(@diagram).haveClass "diagram"
    expect(@diagram).haveClass "sequence-diagram"

  it "has no elements just after creation", ->
    expect(@diagram.find("*").length).toBe 0
  
  describe "SequenceParticipant", ->
    beforeEach ->
      @object = new SequenceParticipant "user"
    
    it "has .participant", ->
      expect(@object).haveClass "participant"
      
    it "has name", ->
      expect(@object.find(".name").text()).toBe "user"
   
    it "has size", ->
      div.append @diagram
      @diagram.append @object
      expect(@object.width()).toBeGreaterThan 0
      expect(@object.height()).toBeGreaterThan 0
  
  describe "SequenceOccurrence", ->

    it "has .occurrence", ->
      beforeEach ->
        @occurr = new SequenceOccurrence

  describe "SequenceFragment", ->

    beforeEach ->
      @fragment = new SequenceFragment "treat all"

    it "has .fragment", ->
      expect(@fragment).haveClass "fragment"

    it "has given name", ->
      expect(@fragment.find(".name").text()).toBe "treat all"

  describe "SequenceRef", ->

    beforeEach ->
      @ref = new SequenceRef "another sequence"

    it "has .ref", ->
      expect(@ref).haveClass "ref"

    it "has given name", ->
      expect(@ref.find(".name").text()).toBe "another sequence"
    
  describe "width", ->
    describe "issue#31", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "Browser", ->
            @alt {
              "[200]": -> @message "GET href resources", "HTTP Server"
              "[301]": -> @ref "GET the moved page"
              "[404]": -> @ref "show NOT FOUND"
            }
          @find(".ref").css(width:256, "padding-bottom":4)
            .find(".tag").css float:"left"
          """
        div.append @diagram
        @layout.layout @diagram

      it "is extended by .ref", ->
        l0 = utils.left @diagram.find(".ref:eq(0)")
        l1 = utils.left @diagram
        expect(@diagram.outerWidth() >= (l0 - l1) + 256)

