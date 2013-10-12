self = require: unless typeof require is "undefined" then require else JUMLY.require
self.require "node-jquery-xhr"
utils = self.require "./jasmine-utils"

describe "Diagram", ->
  Diagram = self.require "Diagram"
  beforeEach ->
    @diagram = new Diagram
    utils.matchers this

  it "has data() of jQuery", ->
    expect(@diagram.data).toBeDefined()

  it "has .diagram", ->
    expect(@diagram).haveClass "diagram"
