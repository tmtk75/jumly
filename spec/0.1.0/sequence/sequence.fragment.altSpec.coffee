description "fragment.alt", ->
    it "should return ownself", ->
        occur = ($.uml ".object").activate()
        frag = $.uml ".fragment"
        alt = frag.alter occur, {"[x > 0]":->}
        (alt is frag).shouldBe true

    scenario "a single fragment", ->
      given "2 objects and an interaction", ->
        @diag = $.uml ".sequence-diagram"
        diag.found "A-frag-1", ->
          @message "call", "B-frag-2"
          @loop @message "call", "B-frag-3"
          @message "call", "B-frag-4"
      when_it "composing", ->
        diag.appendTo $ "body"
        diag.compose()
      then_it "occurrence has fragment", ->
        diag.find(".interaction.activated > .occurrence:eq(0)")
            .find("> .fragment:eq(0)").expect length:1
            
    scenario "three combined fragment", ->
      given "2 objects and an interaction", ->
          @diag = $.uml ".sequence-diagram"
          diag.found "A", ->
              @message "call", "B"
              @alt "[x > 0]": ->
                      @message "a->e", "E"
                   "[x = 0]": ->
                      @message "a->d", "D"
                   "[x < 0]": ->
                      @message "a->c", "C"
      when_it "composing", ->
          diag.appendTo $ "body"
          diag.compose()
      then_it "occurrence has fragment", ->
          diag.find(".interaction.activated > .occurrence:eq(0)")
              .find("> :eq(0)").expect((e) -> e.hasClass "interaction").end()
              .find("> :eq(1)").expect((e) -> e.hasClass "alt")
                  .find("> :eq(0)").expect((e) -> e.hasClass "header").end()
                  .find("> :eq(1)").expect((e) -> e.hasClass "condition").end()
                  .find("> :eq(2)").expect((e) -> e.hasClass "interaction").end()
                  .find("> :eq(3)").expect((e) -> e.hasClass "divider").end()
                  .find("> :eq(4)").expect((e) -> e.hasClass "condition").end()
                  .find("> :eq(5)").expect((e) -> e.hasClass "interaction").end()
                  .find("> :eq(6)").expect((e) -> e.hasClass "divider").end()
                  .find("> :eq(7)").expect((e) -> e.hasClass "condition").end()
                  .find("> :eq(8)").expect((e) -> e.hasClass "interaction").end()
    
    scenario "alt for reactivation, which is a case the returning is null", ->
        given "2 objects and an interaction", ->
            @diag = $.uml ".sequence-diagram"
            diag.found "A", ->
                @alt "[x > 0]": ->
                    @message "a->b", "B"
                    null
        when_it "composing it which null returned", ->
            diag.appendTo $ "body"
            diag.compose()
        then_it "occurrence has fragment", ->
            diag.find(".alt").expect length:1

