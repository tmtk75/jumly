describe "SequenceDiagram", ->
  builder = new JUMLY.SequenceDiagramBuilder

  describe "tagging", ->
    it "should be", ->
      @diag = builder.build """
        @found "Boy", ->
          @message "hello", "Girl"
          @create "Lunch"
        """

      expect($(".object:eq(0)", @diag).hasClass "found").toBeTruthy()
      expect($(".object:eq(2)", @diag).hasClass "created-by").toBeTruthy()
