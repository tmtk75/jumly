describe "class", ->

  describe "JUMLYClassDiagram", ->
    it "should create an instance", ->
      diag = $.jumly ".class-diagram"
      expect(diag.hasClass "diagram").toBeTruthy()
      expect(diag.hasClass "class-diagram").toBeTruthy()
