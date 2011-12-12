BODY = -> $("#TrivialReporter")
describe "usecase", ->
  describe "show-case", ->
    ## Primary Showcase for usecase
    declare = """
              @boundary "JUMLY", ->
                @usecase think:"Thinking Something"
                @usecase rendering:"Rendering Diagram": extend:[think]
              @actor user:use:[think, rendering]
              """
    script    = mkscript "usecase", declare
    diag      = $.jumly.build script
    think     = diag.find(".usecase:eq(0)").self()
    rendering = diag.find(".usecase:eq(1)").self()
    actor     = diag.find(".actor").self()

    it "should have .diagram", ->
      expect(diag.hasClass("diagram")).toBeTruthy()
    
    it "should equal for think", ->
      expect(diag.think).toBe think

    it "should equal for rendering", ->
      expect(diag.rendering).toBe rendering

    it "should equal for actor", ->
      expect(diag.user).toBe actor
      
    it "should be able to be composed", ->
      BODY().append diag
      diag.compose()
      diag.attr "id", "show-case"
      expect($("#show-case").self()).toBe diag


  describe "Builder", ->
    describe "@boundary", ->
      it "should take string as name", ->
        diag = (new JUMLY.UsecaseDiagramBuilder).build "@boundary 'system', ->"
        diag.system = diag.find(".boundary").self()
