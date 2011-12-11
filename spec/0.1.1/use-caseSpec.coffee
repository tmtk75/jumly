describe "use-case", ->

  describe "show-case", ->
    ## Primary Showcase for use-case
    declare = """
              @boundary "JUMLY", ->
                @usecase think:"Thinking Something"
                @usecase render:"Rendering Diagram": extend:[think]
              @actor user: use:[think, render]
              """
    script = mkscript "use-case", declare
    diag   = $.jumly.build script
    think  = diag.find(".use-case:eq(0)").self()
    render = ding.find(".use-case:eq(1)").self()
    actor  = diag.find(".actor").self()

    it "should have .diagram", ->
      expect(diag.hasClass("diagram")).toBeTruthy()
    
    it "should equal for think", ->
      expect(diag.think).toBe think

    it "should equal for render", ->
      expect(diag.render).toBe render

    it "should equal for actor", ->
      expect(diag.actor).toBe actor


  describe "Builder", ->

    describe "@boundary", ->
      it "should take string as name", ->
