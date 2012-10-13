utils = require "./jasmine-utils"
is_node = require("core").env.is_node

describe "SequenceDiagram", ->
  SequenceDiagram = require "SequenceDiagram"

  div = utils.div this

  beforeEach ->
    utils.matchers this
    div.append @diagram = new SequenceDiagram "hello"

  it "has .diagram and .sequence-diagram", ->
    expect(@diagram).haveClass "diagram"
    expect(@diagram).haveClass "sequence-diagram"

  it "has no elements just after creation", ->
    expect(@diagram.find("*").length).toBe 0
  
  describe "SequenceObject", ->
    SequenceObject = require "SequenceObject"
    beforeEach ->
      @object = new SequenceObject "user"
    
    it "has .object", ->
      expect(@object).haveClass "object"
      
    it "has name", ->
      expect(@object.find(".name").text()).toBe "user"
   
    unless is_node
      it "has size", ->
        @diagram.append @object
        expect(@object.width()).toBeGreaterThan 0
        expect(@object.height()).toBeGreaterThan 0
