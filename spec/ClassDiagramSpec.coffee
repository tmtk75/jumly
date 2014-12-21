ClassDiagram = require "ClassDiagram.coffee"

describe "ClassDiagram", ->

  it "should have data() of jQuery", ->
    diag = new ClassDiagram
    expect(diag.data).not.toBeUndefined()
