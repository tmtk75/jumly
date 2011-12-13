BODY = -> $("#TrivialReporter")
describe "class", ->
  describe "JUMLYClassDiagram", ->
    it "should create an instance", ->
      diag = $.jumly ".class-diagram"
      expect(diag.hasClass "diagram").toBeTruthy()
      expect(diag.hasClass "class-diagram").toBeTruthy()

  describe "ClassDiagramBuilder", ->
    describe "@def", ->
      it "should be passed for normalized value", ->
        builder = new JUMLY.ClassDiagramBuilder
        diag = builder.build "@def dog:'Pochi'"
        expect(diag.find("#dog").find(".name").text()).toBe "Pochi"

      it "should throw Error when ID and method name are duplicated", ->
        f = -> (new JUMLY.ClassDiagramBuilder).build "@def declare:'Foo'"
        expect(f).toThrow()
        
  it "should be show-case by manual build", ->
    diag   = $.jumly ".class-diagram"
    animal = $.jumly ".class", "Aniaml"
    diag.append animal
    BODY().append diag
    diag.compose()

  describe "show-case", ->
    diag = $.jumly.build mkscript "class", """
      @def dog:Dog:
        attrs:["age", "origin"]
        methods:["balk", "run"]
      @def cat:Cat:
        attrs:["name"]
        methods:["sleep", "walk"]
      """
    c1st = diag.find(".class:eq(0)").self()
    c2nd = diag.find(".class:eq(1)").self()
    dog  = diag.find("#dog").self()
    cat  = diag.find("#cat").self()

    it "should be findable for dog by ID", ->
      expect(c1st).toBe dog

    it "should be findable for cat by ID", ->
      expect(c2nd).toBe cat

    it "should be refered for dog by property", ->
      expect(diag.dog).toBe dog

    it "should be refered for cat by property", ->
      expect(diag.cat).toBe cat

    it "should be able to be composed", ->
      BODY().append diag
      diag.compose()
      diag.attr "id", "show-case-of-class"
      expect($("#show-case-of-class").self()).toBe diag
