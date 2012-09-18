describe "jQuery", ->
  describe "attr", ->
    describe "data-bind", ->
      ## Relationship b/w data-bind attribute and jQuery.data
      it "should be findable with data", ->
        a = $("<span>").attr("data-bind", 1234)
        expect(1234).toBe a.data("bind")
      
      it "may not be findable through data- attribute", ->
        src = {}
        src.toString = -> "src-object"
        a = $("<span>").attr("data-src", src)
        expect("src-object").toBe a.data("src")

