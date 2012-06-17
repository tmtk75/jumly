describe "meta", ->
  describe "jQuery", ->
    it "should", ->
      b = new JUMLY.SequenceDiagramBuilder
      a = b.build '@found "actor"'
      $("body").append a
      a.compose()
      expect(a.find(".object").length).toBe 1
      expect(a.find(".lifeline").length).toBe 1

  describe "jsdom", ->
    a = $("<span>")
    a.css left:123

    it "supports css", ->
      expect(a.css "left").toBe "123px"

    it "doesn't support offset", ->
      expect(a.offset().left).toBeUndefined()
    
    it "doesn't support position", ->
      expect(a.position().left).not.toBe 123

