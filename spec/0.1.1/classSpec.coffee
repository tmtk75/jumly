BODY = -> $("#TrivialReporter")
describe "class", ->
  describe "JUMLYClassDiagram", ->
    it "should create an instance", ->
      diag = $.jumly ".class-diagram"
      expect(diag.hasClass "diagram").toBeTruthy()
      expect(diag.hasClass "class-diagram").toBeTruthy()

  describe "ClassDiagramBuilder", ->
    describe "@def", ->
      it "should be passed for normalized value"

  it "should be show-case by manual build", ->
    diag   = $.jumly ".class-diagram"
    animal = $.jumly ".class", "Aniaml"
    diag.append animal
    BODY().append diag
    diag.compose()

  ## Show-case.
  it "should be show-case", ->
    diag = $.jumly.DSL(".class-diagram").compileScript mkscript "class", """
      @def dog:Dog:
        attrs:["balk"]
      """
    BODY().append diag
    diag.compose()    
    c1st = diag.find(".class:eq(0)").self()
    dog  = diag.find("#dog").self()
    expect(c1st).toBe dog
    expect(c1st.find(".name").text()).toBe "Dog"
