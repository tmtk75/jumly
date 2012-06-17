describe "Builder", ->
  it "should", ->
    b = new JUMLY.SequenceDiagramBuilder
    a = b.build '@found "actor"'
    $("body").append a
