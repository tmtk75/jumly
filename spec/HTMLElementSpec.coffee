require "node-jquery"
HTMLElement = require "HTMLElement"

describe "HTMLElement", ->

  it "should have data() of jQuery", ->
    elem = new HTMLElement
    expect(elem.data).not.toBeUndefined()
    expect(elem.data).toEqual $("<div>").data
 
  describe "to_css_name", ->

    it "returns css class name for given function", ->
      f = HTMLElement.to_css_name
      expect(f "SequenceObject").toBe "object"
