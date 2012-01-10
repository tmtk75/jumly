$ ->
  appose = (a)-> $("body").append a; a.compose(); a.css("z-index":100)

  Builder = JUMLY.SequenceDiagramBuilder
  describe "sequence", ->
    describe "@note", ->
      it "should create a .note", ->
        appose diag = (new Builder).build '@note "hello"'
        expect(diag.find(".note").length).toBe 1
        expect(diag.find(".note").text()).toBe "hello"

