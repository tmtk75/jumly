describe "JUMLY", ->
  describe "DiagramBuilder", ->
    it "should have its own scope", ->
      script = mkscript "usecase", """
        window.a1 = 123
        a1 = 321
        this.a1 = 111
        """
      builder = new JUMLY.DiagramBuilder
      builder.build script
      expect(window.a1 ).toBe 123
      expect(builder.a1).toBe 111
      
    it "should be extended with 'extends'", ->
      script = mkscript "usecase", """
        @run "A", "B"
        """
      class MyBuilder extends JUMLY.DiagramBuilder
      MyBuilder::run = -> this.ran = "abc"
      builder = new MyBuilder
      builder.build script
      expect(builder.ran).toBe "abc"
  
    it "should build HTMLScriptElement after DOM tree is built", ->
      a0 = mkscript "usecase", "window.b1 = 12341234"
      a1 = mkscript "usecase", "window.b2 = 44332211"
      a2 = mkscript "usecase", "window.b3 = 55667788"
      a1.addClass "ignored"
      div = $("<div>").append(a0).append(a1).append(a2)
      scripts = JUMLY.DiagramBuilder.selectHTMLScriptElements div
      expect(scripts.length).toBe 2
  
    beforeEach -> @addMatchers
      toBeLessThan: (expected)-> @actual < expected
      toBeFunction: -> @actual.constructor is Function
        
    it "should return the appropriate instance of DiagramBuilder for given HTMLScriptElement", ->
      builder = JUMLY.DiagramBuilder.new_ mkscript "usecase", "window.c1 = 112233"
      expect(builder).not.toBeUndefined()
      expect(builder.build).toBeFunction()
  
  
    describe "Event", ->
      it "should", ->
        $("*").on "build.before", -> window.d0 = "build.before"
        script = mkscript "usecase", ""
        builder = JUMLY.DiagramBuilder.new_ script
        builder.build()
  
        expect(window.d0).toBe "build.before"

    it "should convert text to JUMLYDiagramElement"


  describe "ClassDiagramBuilder", ->
    it "should build JUMLYClassDiagram", ->
      builder = new JUMLY.ClassDiagramBuilder
      diag = builder.build "@def 'Animal'"
      expect(diag.hasClass "diagram").toBeTruthy()
      expect(diag.hasClass "class-diagram").toBeTruthy()

    
  describe "UsecaseDiagramBuilder", ->
    it "should build JUMLYUsecaseDiagram", ->
      builder = new JUMLY.UsecaseDiagramBuilder
      diag = builder.build "@boundary 'sys', ->"
      expect(diag.hasClass "diagram").toBeTruthy()
      expect(diag.hasClass "usecase-diagram").toBeTruthy()


  describe "SequenceDiagramBuilder", ->
    it "should build JUMLYSequenceDiagram", ->
      builder = new JUMLY.SequenceDiagramBuilder
      diag = builder.build "@found 'It', ->"
      expect(diag.hasClass "diagram").toBeTruthy()
      expect(diag.hasClass "sequence-diagram").toBeTruthy()
