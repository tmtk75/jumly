self = require: unless typeof require is "undefined" then require else JUMLY.require
self.require "node-jquery-xhr"
ClassDiagram = self.require "ClassDiagram"

describe "ClassDiagram", ->

  it "should have data() of jQuery", ->
    diag = new ClassDiagram
    expect(diag.data).not.toBeUndefined()
