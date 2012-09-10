describe "SequenceDiagram", ->
  builder = new JUMLY.SequenceDiagramBuilder

  describe "spacing", ->
    beforeEach ->
      @diag = builder.build """
        @found "Boy", ->
          @message "say, hello!", "Mother"
          @create "Lunch"
        """
      $("body").append @diag
      @diag.compose()
    
    afterEach ->
      @diag.css visibility:"hidden"

    it "should have two spacings", ->
      spacings = @diag.find(".spacing")
      expect(spacings[0]).not.toBeUndefined()
      expect(spacings[1]).not.toBeUndefined()
      expect(spacings[2]).toBeUndefined()

    it "should have created-by", ->
      a = @diag.find(".object:eq(2)")[0]
      b = @diag.find(".created-by")[0]
      expect(a).toBe b

    describe "1st spacing", ->
      it "should have classes", ->
        a = @diag.find(".spacing").find(":eq(0)")
        expect(a.hasClass "found").toBeTruthy()
        expect(a.hasClass "created-by").toBeFalsy()

    describe "2nd spacing", ->
      it "should have classes", ->
        a = @diag.find(".spacing").find(":eq(1)")
        expect(a.hasClass "found").toBeFalsy()
        expect(a.hasClass "created-by").toBeTruthy()
