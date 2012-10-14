utils = require "./jasmine-utils"

describe "SequenceDiagramBuilder", ->
  SequenceDiagramBuilder = require "SequenceDiagramBuilder"

  beforeEach ->
    @builder = new SequenceDiagramBuilder
    @diagram = @builder.diagram()
    utils.matchers this

  describe "diagram", ->

    it "returns diagram", ->
      expect(@builder.diagram()).haveClass "diagram"
  
  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node).haveClass "diagram"
    
  describe "found", ->

    it "returns itself", ->
      expect(@builder.found "fiz").toBe @builder

    it "gives an object having .found", ->
      @builder.found "biz"
      obj = @diagram.find ".object"
      expect(obj.length).toBe 1
      expect(obj).haveClass "found"
      expect(obj.find(".name").text()).toBe "biz"
    
  describe "message", ->
    beforeEach ->
      @builder.found("foo")
              .message "call", "bar"
  
    it "returns itself", ->
      expect(@builder.found("foo").message "call").toBe @builder
    
    it "gives an interaction and an occurrence", ->
      iter = @diagram.find "> .interaction"
      expect(iter.length).toBe 1
      expect(iter.find("> .occurrence").length).toBe 1
      expect(@diagram.find("> .interaction > .occurrence > .interaction").length).toBe 1

  describe "create", ->

  describe "destroy", ->

  describe "reply", ->

  describe "ref", ->

  describe "loop", ->

  describe "alt", ->

  describe "reactivate", ->

  describe "lost", ->
