describe "use-case", ->

  ## Primary Showcase for use-case
  it "should be rendered", ->
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
    
    expect(diag.hasClass("diagram")).toBeTruthy()
    expect(diag.think ).toBe think
    expect(diag.render).toBe render
    expect(diag.actor ).toBe actor


  describe "Builder", ->

    describe "@boundary", ->
      it "should take string as name", ->
