describe "JUMLYDiagram", ->
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
      expect(-> a._regByRef_ id, {}).toThrow()
      # Also for b, Error is thrown
      expect(-> b._regByRef_ id, {}).toThrow()
