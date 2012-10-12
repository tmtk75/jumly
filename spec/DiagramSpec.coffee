require "node-jquery"
matchers = require "./jasmine-matchers"

describe "Diagram", ->
  Diagram = require "Diagram"
  beforeEach ->
    @diagram = new Diagram
    matchers.setup this

  it "has data() of jQuery", ->
    expect(@diagram.data).toBeDefined()

  it "has .diagram", ->
    expect(@diagram).haveClass "diagram"
