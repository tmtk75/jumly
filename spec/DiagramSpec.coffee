require "node-jquery"
utils = require "./jasmine-utils"

describe "Diagram", ->
  Diagram = require "Diagram"
  beforeEach ->
    @diagram = new Diagram
    utils.matchers this

  it "has data() of jQuery", ->
    expect(@diagram.data).toBeDefined()

  it "has .diagram", ->
    expect(@diagram).haveClass "diagram"
