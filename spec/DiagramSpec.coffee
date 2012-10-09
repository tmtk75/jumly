require "node-jquery"
Diagram = require "Diagram"

describe "Diagram", ->

  beforeEach ->
    @diagram = new Diagram

  it "has data() of jQuery", ->
    expect(@diagram.data).toBeDefined()

  it "has .diagram", ->
    expect(@diagram).haveClass "diagram"
