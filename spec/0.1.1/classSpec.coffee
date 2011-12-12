BODY = -> $("#TrivialReporter")
describe "class", ->

  describe "JUMLYClassDiagram", ->
    it "should create an instance", ->
      diag = $.jumly ".class-diagram"
      expect(diag.hasClass "diagram").toBeTruthy()
      expect(diag.hasClass "class-diagram").toBeTruthy()

  it "should be show-case by manual build", ->
    diag   = $.jumly ".class-diagram"
    animal = $.jumly ".class", "Aniaml"
    diag.append animal
    BODY().append diag
