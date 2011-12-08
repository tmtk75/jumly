ScriptParser = JUMLY.ScriptParser

describe "Parser", ->
  makeScript = (type, script)->
                 $("<script>").attr("type", "application/jumly+#{type}")
                              .text script

  it "should have its own scope", ->
    script = makeScript "use-case", """
                        window.a1 = 123
                        a1 = 321
                        this.a1 = 111
                        """

    parser = new ScriptParser
    parser.parse script
    expect(window.a1).toBe 123
    expect(parser.a1).toBe 111

  it "should parse JUMLY DSL in a HTMLScriptElement", ->


describe "Appender", ->
  it "append it just after the HTMLScriptElement"
    
