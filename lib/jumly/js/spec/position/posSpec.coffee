describe "position", ->
  it "should be correct", ->
    $("body").append (new JUMLY.SequenceDiagramBuilder).build """
    @found a:"Boy", ->
      @message "call", b:"Mother", ->
    """
    $(".diagram").self().compose()
    a = $("#a")
    b = $("#b")
    expect(a.css "left").toBe "0px"
    s = $.jumly.preferences(".sequence-diagram").compose_span
    expect(b.css "left").toBe (a.outerWidth() + s) + "px"
