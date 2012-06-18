describe "position", ->
  describe "horizontal", ->
    it "should be correct", ->
      $("body").append (new JUMLY.SequenceDiagramBuilder).build """
      @found a:"Boy", ->
        @message "call", b:"Mother", ->
      """
      $(".diagram").self().compose()
      a = $("#a")
      b = $("#b")
      expect(a.css "left").toBe "0px"
      packing = $(".horizontal.packing").width()
      expect(b.css "left").toBe (a.outerWidth() + packing) + "px"
