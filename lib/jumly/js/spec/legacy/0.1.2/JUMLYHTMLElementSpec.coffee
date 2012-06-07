describe "JUMLYHTMLElement", ->

  describe "JUMLYRelationship", ->
    
    it "should be built", ->
      a = src:{}, dst:{}
      r = new JUMLY.Relationship a  # arguments are passed by named parameters.
      expect(r.find(".name").length).toBe 1
      expect(r.src).toBe a.src
      expect(r.dst).toBe a.dst
