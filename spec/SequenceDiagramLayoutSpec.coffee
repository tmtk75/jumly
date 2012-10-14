require "core"
require "jquery.ext"
SequenceDiagramLayout = require "SequenceDiagramLayout"
SequenceDiagram = require "SequenceDiagram"
SequenceObject = require "SequenceObject"

describe "SequenceDiagramLayout", ->

  beforeEach ->
    @layout = new SequenceDiagramLayout

  it "has layout", ->
    expect(typeof @layout.layout).toBe "function"
  
  it "determines the size", ->
    diag = new SequenceDiagram
    diag.append new SequenceObject "foobar"
    @layout.layout diag
    expect(diag.width()).toBeGreaterThan 0
    expect(diag.height()).toBeGreaterThan 0
