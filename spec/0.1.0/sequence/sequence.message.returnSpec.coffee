description "message.return", ->
    scenario "reply to left", ->
        given "an .object", ->
            @diag = $.uml ".sequence-diagram"
            @diag.found "A", ->
                @message "b", "B", ->
                    @message "c", "C", ->
                        @reply "", "A"
        when_it "compose", ->
            diag.appendTo $ "body"
            diag.compose()
        then_it "width", ->
            diag.find(".return:eq(0)").offset().left
                .shouldBe diag.find(".occurrence:eq(0)").offset().left
    
    scenario "reply to right", ->
        given "an .object", ->
            @diag = $.uml ".sequence-diagram"
            @diag.found "A", ->
                @message "b", "B", ->
                    @message "c", "C", ->
                        @message "a", "A", ->
                            @reply "", "B"
        when_it "compose", ->
            diag.appendTo $ "body"
            diag.compose()
        then_it "width", ->
            diag.find(".return:eq(0)").outerRight()
                .shouldBe diag.find(".occurrence:eq(1)").offset().left

    scenario "reply to right", ->
        given "an .object", ->
            @diag = $.uml ".sequence-diagram"
            @diag.found "A", ->
                @message "b", "B", ->
                    @reply "back"
        when_it "compose", ->
            diag.appendTo $ "body"
            diag.compose()
        then_it "width", ->

