utils = require "./jasmine-utils.coffee"
Diagram = require "Diagram.coffee"

describe "Diagram", ->
  beforeEach ->
    @diagram = new Diagram
    utils.matchers this

  it "has data() of jQuery", ->
    expect(@diagram.data).toBeDefined()

  it "has .diagram", ->
    expect(@diagram).haveClass "diagram"
