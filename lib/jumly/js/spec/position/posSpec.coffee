describe "position", ->
  it "should be", ->
    $("body").append (new JUMLY.SequenceDiagramBuilder).build """
    @found "Boy", ->
      @message "call", "Mother", ->
    """
    $(".diagram").self().compose()
