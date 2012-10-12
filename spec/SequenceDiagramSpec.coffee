require "./jasmine-matchers"
utils = require "./spec-utils"

describe "SequenceDiagram", ->
  SequenceDiagram = require "SequenceDiagram"

  div = utils.setup this

  beforeEach ->
    jasmine_matchers.matchers this
    div.append @diagram = new SequenceDiagram "hello"

  
  describe "SequenceObject", ->
    SequenceObject = require "SequenceObject"
    beforeEach ->
      @object = new SequenceObject "user"
    
    it "has .object", ->
      expect(@object).haveClass "object"
      
    it "has name", ->
      expect(@object.find(".name").text()).toBe "user"
    
    it "", ->
      @diagram.append @object
