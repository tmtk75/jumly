describe "JUMLY", ->
  describe "DiagramBuilder", ->
    it "should have its own scope", ->
      builder = new JUMLY.ClassDiagramBuilder
      builder.build """
        window.a1 = 123
        a1 = 321
        this.a1 = 111
        """
      expect(window.a1 ).toBe 123
      expect(builder.a1).toBe 111
      
    it "should be extended with 'extends'", ->
      class MyDiagramBuilder extends JUMLY.DiagramBuilder
      MyDiagramBuilder::run = -> this.ran = "abc"
      class MyDiagram extends JUMLY.Diagram
      JUMLY.define ".my-diagram", MyDiagram
      builder = new MyDiagramBuilder
      builder.build '@run "A", "B"'
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
  
  
    describe "Event", ->
      it "should call 'build.after' before build for sequence", ->
        builder = new JUMLY.SequenceDiagramBuilder()
        diag = builder.build """
          @found 'Event build.after spec for sequence', ->
          @diagram.on "build.after", -> window.d0 = "build.after called"
          """
        expect(window.d0).toBe "build.after called"


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

$ ->
  enable = (b)-> JUMLY.Preferences "document.id.validation.enable":b
  describe "JUMLY", ->
    describe "Builder", ->
      describe "ID, Ref duplication", ->
        it "should throw an Error when building same ID in body", ->
          enable true
          b = new JUMLY.SequenceDiagramBuilder
          $("body").append b.build "@found 'Monkey Magic', ->"
          expect(-> b.build "@found 'Monkey Magic', ->").toThrow()
          enable false
    
        it "should throw an Error when @creating same Ref in a diagram", ->
          b = new JUMLY.SequenceDiagramBuilder
          expect(-> b.build "@found 'Line999', -> @create '', 'Line999'").toThrow()
    
        it "should not throw an Error when @messaging same Ref in a diagram because it's a self-call", ->
          b = new JUMLY.SequenceDiagramBuilder
          b.build "@found 'Line999', -> @message '', 'Line999'"
    
        describe "Configuration", ->
          it "should be no validation for duplication of ID in default", ->
            b = new JUMLY.SequenceDiagramBuilder
            $("body").append b.build "@found 'Monkey Magic-1', ->"
            b.build "@found 'Monkey Magic-1', ->"
    
          it "should validate if only configuring", ->
            enable true
            b = new JUMLY.SequenceDiagramBuilder
            $("body").append b.build "@found 'Monkey Magic-2', ->"
            expect(-> b.build "@found 'Monkey Magic-2', ->").toThrow()
            enable false

        describe "Reserved name", ->
          it "should build successfully for actee which has name 'JUMLY'", ->
            b = new JUMLY.SequenceDiagramBuilder
            diag = b.build """
              @found 'You', ->
                @message 'use', 'JUMLY'
              """
            $("body").append diag
            diag.compose()
