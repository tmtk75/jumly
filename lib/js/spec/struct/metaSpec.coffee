describe "meta", ->
  describe "jQuery", ->
    it "should be supported", ->
      $("body").append $("<span>").addClass("meta").addClass("jQuery")
      a = $("body .meta.jQuery")
      expect(a.length).toBe 1

  describe "jsdom", ->
    a = $("<span>")
    a.css left:123

    it "supports css", ->
      expect(a.css "left").toBe "123px"

    it "doesn't support offset", ->
      expect(a.offset().left).not.toBe 123
    
    it "doesn't support position", ->
      expect(a.position().left).not.toBe 123

