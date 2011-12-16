$ ->
  append = (a)-> $("body").append a
  describe "sequence", ->
    describe "show-case", ->
      builder = new JUMLY.SequenceDiagramBuilder
      dsl = """
            @found "An usual user", ->
              @message "render", "A diagram you want"
              @create slide:"A new slide", ->
                @message "init"
              @message "improve", slide
            """
      diag = builder.build dsl
      append diag
      diag.compose()

    it "should "
