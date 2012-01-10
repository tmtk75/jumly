$ ->
  appose = (a)-> $("body").append a; a.compose(); a.css("z-index":100)

  Builder = JUMLY.SequenceDiagramBuilder
  describe "sequence", ->
    describe "@note", ->
      it "should create a .note", ->
        appose diag = (new Builder).build '@note "hello"'
        expect(diag.find(".note").length).toBe 1
        expect(diag.find(".note").text()).toBe "hello"

      it "should have folded effect for class .fold.top-right", ->
        appose diag = (new Builder).build '''
          @note "Folded note"
          @diagram.find(".note").addClass("fold").addClass("top-right")
          '''
        # How do I assert this?

      describe ".object", ->
        it "should", ->
          appose diag = (new Builder).build '''
            @found "You", ->
            @note you, "and I"
            '''
