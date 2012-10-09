require "node-jquery"
require "./jasmine-matchers"

describe "Diagram", ->
  Diagram = require "Diagram"
  beforeEach ->
    @diagram = new Diagram
    jasmine_matchers.matchers this

  it "has data() of jQuery", ->
    expect(@diagram.data).toBeDefined()

  it "has .diagram", ->
    expect(@diagram).haveClass "diagram"
