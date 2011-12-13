describe "JUMLYDiagram", ->
  describe "@_regByRef_", ->
    it "should throw Error if duplicated property is registered", ->
      class TentativeDiagram extends JUMLY.Diagram
