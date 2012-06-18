describe "JUMLYDiagram", ->
  enable = (b)-> JUMLY.Preferences "document.id.validation.enable":b
  
  describe "@_regByRef_", ->
    it "should throw Error if duplicated property is registered", ->
      class TentativeDiagram extends JUMLY.Diagram

    it "should throw Error if ID already exists", ->
      class MyDiagram extends JUMLY.Diagram
      MyDiagram::build = ->
      a = new MyDiagram
      b = new MyDiagram
      id = "_regByRef_spec_for_duplicated_id"
      a._regByRef_ id, {}
      enable true
      expect(-> a._regByRef_ id, {}).toThrow()
      # Also for b, Error is thrown. ID check is document widely.
      $("body").append $("<div>").attr id:id
      expect(-> b._regByRef_ id, {}).toThrow()
      enable false
      
    it "should contain the name of diagram for its error message", ->
      class YourDiagram extends JUMLY.Diagram
      YourDiagram::build = ->
      diag = new YourDiagram
      try
        diag._regByRef_ "_your_diagram_id"
        diag._regByRef_ "_your_diagram_id"
      catch err
        expect(err.message.match /.*YourDiagram.*/).toBeTruthy()

  it "should add 'diagram'", ->
    class MyFooDiagram extends JUMLY.Diagram
    expect((new MyFooDiagram).hasClass "diagram") 
