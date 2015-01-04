utils = require "./jasmine-utils.coffee"

describe "Diagram", ->
  Diagram = require "Diagram.coffee"
  beforeEach ->
    @diagram = new Diagram
    utils.matchers this

  it "has data() of jQuery", ->
    expect(@diagram.data).toBeDefined()

  it "has .diagram", ->
    expect(@diagram).haveClass "diagram"
