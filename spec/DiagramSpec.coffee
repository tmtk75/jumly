Diagram = require "Diagram"

describe "Diagram", ->

  it "should have data() of jQuery", ->
    diag = new Diagram
    expect(diag.data).not.toBeUndefined()
