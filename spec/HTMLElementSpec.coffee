require "node-jquery"
HTMLElement = require "HTMLElement"

describe "HTMLElement", ->

  it "should have data() of jQuery", ->
    elem = new HTMLElement
    expect(elem.data).not.toBeUndefined()
    expect(elem.data).toEqual $("<div>").data
  
  it "should have itself in data()"

