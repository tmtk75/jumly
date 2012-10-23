utils = require "./jasmine-utils"
is_node = require("core").env.is_node

describe "SequenceDiagram", ->
  SequenceDiagram = require "SequenceDiagram"
  div = utils.div this

  beforeEach ->
    utils.matchers this
    @diagram = new SequenceDiagram "hello"

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
        div.append @diagram
        @diagram.append @object
        expect(@object.width()).toBeGreaterThan 0
        expect(@object.height()).toBeGreaterThan 0
  
  describe "SequenceOccurrence", ->

    it "has .occurrence", ->
      SequenceOccurrence = require "SequenceOccurrence"
      beforeEach ->
        @occurr = new SequenceOccurrence

  describe "SequenceRef", ->

    SequenceRef = require "SequenceRef"
    beforeEach ->
      @ref = new SequenceRef "another sequence"

    it "has .ref", ->
      expect(@ref).haveClass "ref"

    it "has given name", ->
      expect(@ref.find(".name").text()).toBe "another sequence"
    
