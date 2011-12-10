describe "JUMLY.DiagramBuilder", ->
  it "should have its own scope", ->
    script = mkscript "use-case", """
      window.a1 = 123
      a1 = 321
      this.a1 = 111
      """
    builder = new JUMLY.DiagramBuilder
    builder.build script
    expect(window.a1 ).toBe 123
    expect(builder.a1).toBe 111
    
  it "should be extended with 'extends'", ->
    script = mkscript "use-case", """
      @run "A", "B"
      """
    class Mybuilder extends JUMLY.DiagramBuilder
    Mybuilder::run = -> this.ran = "abc"
    builder = new Mybuilder
    builder.build script
    expect(builder.ran).toBe "abc"

  it "should build HTMLScriptElement after DOM tree is built", ->
    a0 = mkscript "use-case", "window.b1 = 12341234"
    a1 = mkscript "use-case", "window.b2 = 44332211"
    a2 = mkscript "use-case", "window.b3 = 55667788"
    a1.addClass "ignored"
    div = $("<div>").append(a0).append(a1).append(a2)
    scripts = JUMLY.DiagramBuilder.selectHTMLScriptElements div
    expect(scripts.length).toBe 2

  beforeEach -> @addMatchers
      toBeLessThan: (expected)-> @actual < expected
      toBeFunction: -> @actual.constructor is Function
      
  it "should return the appropriate instance of DiagramBuilder for given HTMLScriptElement", ->
    builder = JUMLY.DiagramBuilder.new_ mkscript "use-case", "window.c1 = 112233"
    expect(builder).not.toBeUndefined()
    expect(builder.build).toBeFunction()


  describe "Event", ->
    
    it "should", ->
      $("*").on "build.before", -> window.d0 = "build.before"

      script = mkscript "use-case", ""
      builder = JUMLY.DiagramBuilder.new_ script
      builder.build()

      expect(window.d0).toBe "build.before"
