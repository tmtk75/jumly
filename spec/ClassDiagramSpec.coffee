ClassDiagram = require "ClassDiagram"

describe "ClassDiagram", ->

  it "should have data() of jQuery", ->
    diag = new ClassDiagram
    expect(diag.data).not.toBeUndefined()
