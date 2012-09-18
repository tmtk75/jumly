describe "Browser", ->
  describe "Firefox", ->
    it "should be", ->
      $("body").append a = $("<div>")
      expect(a.css("left")).toBe "auto"
