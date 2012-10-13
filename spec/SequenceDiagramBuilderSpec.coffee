utils = require "./jasmine-utils"
is_node = require("core").env.is_nod

describe "SequenceDiagramBuilder", ->
  SequenceDiagramBuilder = require "SequenceDiagramBuilder"

  div = utils.div this

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
      expect(@builder.found "foo").toBe @builder

    it "gives an object", ->
      expect(@diagram.find(".object").length).toBe 1

  describe "message", ->
    beforeEach ->
      @builder.found("foo")
              .message "call", "bar"
  
    it "returns itself", ->
      expect(@builder.found("foo").message "call").toBe @builder

  describe "create", ->

  describe "destroy", ->

  describe "reply", ->

  describe "ref", ->

  describe "loop", ->

  describe "alt", ->

  describe "reactivate", ->

  describe "lost", ->
