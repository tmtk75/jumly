$ ->
  append = (a)-> $("body").append a
  Builder = JUMLY.SequenceDiagramBuilder
  describe "sequence", ->
    describe "@note", ->
      it "should create a .note", ->
        diag = (new Builder).build """
          @note "hello"
          """
        expect(diag.find(".note").length).toBe 1
        
