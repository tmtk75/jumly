describe "Builder", ->
  it "should", ->
    b = new JUMLY.SequenceDiagramBuilder
    a = b.build '@found "actor"'
    $("body").append a
    a.compose()
    expect(a.find(".object").length).toBe 1
    expect(a.find(".lifeline").length).toBe 1
