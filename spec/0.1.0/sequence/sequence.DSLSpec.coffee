uml = u = $.uml
description "sequence-diagram.DSL", ->

    description "@beforeCompose", ->

        it "should run a closure before composing", ->
            diag = u ".sequence-diagram"
            diag.found "", ->
                @beforeCompose (e, d) ->
                    d.foobar = 1
                @afterCompose (e, d) ->
                    d.bizbuz = 2 if d.foobar is 1
            diag.compose()
            expect(diag.foobar).toBe 1
            expect(diag.bizbuz).toBe 2
  

    description "@afterCompose", ->

        it "should run a closure after composing", ->
            diag = u ".sequence-diagram"
            counter = 0
            diag.found "", ->
                @afterCompose (e, d) ->
                    counter += 1
            diag.compose()
            expect(counter).toBe 1


    shared_behavior "given a .sequence_diagram", ->
        given "given a .sequence_diagram", ->
            @diagram = uml ".sequence-diagram"

    description "found", ->
      shared_scenario "found context", ->
        it_behaves_as "given a .sequence_diagram"
        then_it "has a function .message", ->
          diagram.found "Actor", ->
            (typeof this["message"]).shouldBe 'function'

      scenario "returning", ->
        it_behaves_as "given a .sequence_diagram"
        @that = if this.window then window else this
        when_it "A sequence starts", ->
          that.a = diagram.found aaabbb1111:"A", ->
            that.b = this
            that.c = @message "call", "Bbbbddd111222", ->
            1234
        then_it "found returns InteractionContext", ->
          (that.a is that.b).shouldBe true
        then_it "returns different context from ownself", ->
          (that.b is that.c).shouldBe false
        then_it "InteractionContext has the last value evaluated in the context", ->
          that.a.last.shouldBe 1234

    description "returning InteractionContext", ->
      suffix = "-returning Inter"
      @diagram = uml ".sequence-diagram"
      @that1 = {}
      @that2 = {}
      that1.a = diagram.found "A#{suffix}", ->
        that1.b = @message "call", "B#{suffix}", -> that2.b = this
        that1.c = @message "call", ->
        that1.d = @create  "C#{suffix}", ->
        that1.e = @destroy "B#{suffix}-1", ->
        that1.f = @reply ->
        that1.g = @ref ->
        that1.h = @loop ->
        that1.i = @reactivate "call", "B#{suffix}-2"
      it "message",    -> (that1.b.constructor is that1.a.constructor).shouldBe true
      it "selfcall",   -> (that1.c.constructor is that1.a.constructor).shouldBe true
      it "create",     -> (that1.d.constructor is that1.a.constructor).shouldBe true
      it "destroy",    -> (that1.e is null).shouldBe true  ## No occurrence at the actee of destroy.
      it "reply",      -> (that1.f is null).shouldBe true  ##
      it "ref",        -> (that1.g is null).shouldBe true  ##
      it "loop",       -> (that1.h.constructor is that1.a.constructor).shouldBe true
      it "reactivate", -> (that1.i.constructor is that1.a.constructor).shouldBe true
      ctxtA = null
      that1.A = diagram.found "A#{suffix}-3", ->
        ctxtA = this
        that1.B = @message "call", "B#{suffix}-4"
        that1.C = @message "call"
        that1.D = @create  "C#{suffix}-5"
      it "message without action, different one",  -> (not(that1.B is ctxtA) and ctxtA.constructor is that1.B.constructor).shouldBe true
      it "selfcall without action, different one", -> (not(that1.C is ctxtA) and ctxtA.constructor is that1.C.constructor).shouldBe true
      it "create without action, different one",   -> (not(that1.D is ctxtA) and ctxtA.constructor is that1.D.constructor).shouldBe true
      ### NOTE: I'm contemplating whethere @message returns always InteractionContext without action or not.
      # NOTE: Tentatively, not return null
      it "message without action, different one",  -> (that1.B is null).shouldBe true
      it "selfcall without action, different one", -> (that1.C is null).shouldBe true
      it "create without action, different one",   -> (that1.D is null).shouldBe true
      ###

    description "goal", ->
        scenario "A order in a family restaurant", ->
            it_behaves_as "given a .sequence_diagram"
            when_it "A sequence starts", ->
                diagram.found "Customer", ->
                    @message "ask", "Hole Staff", ->
                        @message "find a handy terminal", ->
                    @message "order a set menu", "Hole Staff", ->
                        @message "input the order", "Handy Terminal", ->
                            @create "Order", ->
                                @message "validate the pair"
                            @message "tell the order", "Kitchen Staff", ->
                                @create "cook", "Set Menu", ->
                        @message "provide the dish", "Customer", ->
                    @message "eat"
            and_ ->
                diagram.appendTo $ "body"
                diagram.compose()
            then_it "some .interations are created", ->
                diagram.find(".interaction").not(".activated").length.shouldBe 10

    description "complexity", ->
        scenario "reactivating with @message", ->
            given "a diagram", -> @diagram = $.uml ".sequence-diagram"
            when_it "a sequence starts", ->
                diagram.found "A", ->
                    @message "call", "B", ->
                    @reactivate @message "call", "B", ->
            and_ -> (diagram.appendTo $ "body").self().compose()
            then_it "diagram has two interactions", ->
                diagram.find("> .interaction.activated").expect(length: 2)
                       .filter(":eq(0)")
                           .find("> .occurrence").expect(length: 1)
                               .find("> .interaction").expect(length: 1).end()
                           .end().end()
                       .filter(":eq(1)")
                           .find("> .occurrence").expect(length: 1)
                               .find("> .interaction").expect(length: 1).end()
        
        scenario "reactivating", ->
            given "a diagram", -> @diagram = $.uml ".sequence-diagram"
            when_it "a sequence starts", ->
                diagram.found "A", ->
                    @message "b", "B", ->
                    @reactivate "c", "C", ->
            and_ -> (diagram.appendTo $ "body").self().compose()
            then_it "diagram has two interactions, which is same to 'with @message'", ->
                diagram.find("> .interaction.activated").expect(length: 2)
                       .filter(":eq(0)")
                           .find("> .occurrence").expect(length: 1)
                               .find("> .interaction").expect(length: 1).end()
                           .end().end()
                       .filter(":eq(1)")
                           .find("> .occurrence").expect(length: 1)
                               .find("> .interaction").expect(length: 1).end()
                
        scenario "reactivating covered with @loop", ->
            given "a diagram", -> @diagram = $.uml ".sequence-diagram"
            when_it "a sequence starts", ->
                diagram.found "A", ->
                    @message "b", "B", ->
                    @loop @reactivate "c", "C", ->
            and_ -> (diagram.appendTo $ "body").self().compose()
            then_it "diagram has two interactions, which is same to 'with @message'", ->
                diagram.find("> .fragment").expect(length: 1)

    description "noting", ->
        ## Note is basically after destination occurrence
        scenario "note before an interaction", ->
            it_behaves_as "given a .sequence_diagram"
            given "a noted interaction", ->
                diagram.found "A", ->
                    @note "It's a first call."
                    @message "a->b", "B"
                diagram.appendTo $ "body"
                diagram.compose()
            then_it "no note because of no active interaction", ->
                $(".note", diagram).expect length:0

        scenario "note after an interaction", ->
            it_behaves_as "given a .sequence_diagram"
            given "a noted interaction", ->
                diagram.found "A", ->
                    @message "a->b", "B"
                    @note "It's a first call."
                diagram.appendTo $ "body"
                diagram.compose()
            then_it "last occurrence has no children", ->
                $(".interaction:not(.activated):eq(0) > .occurrence:eq(0)", diagram).expect(length:1)
                    .find("> *").expect length:0
            then_it "note is after the destination occurrence", ->
                $(".interaction:not(.activated):eq(0)", diagram)
                    .find("> *:eq(0)").expect((e) -> e.hasClass "message").end()
                    .find("> *:eq(1)").expect((e) -> e.hasClass "occurrence").end()
                    .find("> *:eq(2)").expect((e) -> e.hasClass "note")

        scenario "note for interaction", ->
            it_behaves_as "given a .sequence_diagram"
            given "a noted interaction", ->
                diagram.found "A", ->
                    @message "a->b", "B"
                    @note "It's a first call."
                    @message "a->b", "B"
                diagram.appendTo $ "body"
                diagram.compose()
            then_it "", ->
                $(".interaction:not(.activated):eq(0)", diagram)
                    .find("> *:eq(0)").expect((e) -> e.hasClass "message").end()
                    .find("> *:eq(1)").expect((e) -> e.hasClass "occurrence").end()
                    .find("> *:eq(2)").expect((e) -> e.hasClass "note")
                $(".interaction:not(.activated):eq(1)", diagram)
                    .find("> .note").expect length:0

    description "@loop", ->

        scenario "2 objects A", ->
            given "2 objects and an interaction", ->
                @diag = $.uml ".sequence-diagram"
                diag.found "A", ->
                    @loop @message "call", "B"
            when_it "composing", ->
                diag.appendTo $ "body"
                diag.compose()
            then_it "composition", ->
                diag.find(".interaction.activated > .occurrence:eq(0) > .fragment").expect length:1
            and_ "having .fragment", ->
                diag.find(".fragment").expect length:1
            and_ "having .loop", ->
                diag.find(".fragment.loop").expect length:1

        scenario "2 objects B", ->
            given "2 objects and an interaction", ->
                @diag = $.uml ".sequence-diagram"
                diag.found "A", ->
                    @loop @message "call", "B", ->
            when_it "composing", ->
                diag.appendTo $ "body"
                diag.compose()
            then_it "composition", ->
                diag.find(".interaction.activated > .occurrence:eq(0) > .fragment").expect length:1

        it "should accept an acts, and run it in a new loop fragment", ->
            diag = $.jumly ".sequence-diagram"
            diag.found "A", ->
                @message "no", "Without"
                @loop ->
                    @create "b"
                    @message "c", "C"
            .compose $ "body"
            expect(diag.find(".loop").length).toBe 1
            expect(diag.find(".loop .message").length).toBe 2
            expect(diag.find(".object").length).toBe 4

    description "script tag", ->

        it 'is able to write a DSL like', ->
            script = $("<script>").html """
                @found "User", ->
                    @message "turn on", "Mobile", ->
                        @message "connect to", "Basepoint"
                """
            diag = $.jumly.DSL('.sequence-diagram').compileScript script
            diag.find(".interaction:not(.activated)").expect length:2
            diag.appendTo $ "body"
            diag.compose()

        it 'should load script node', ->
            script = $("<script>").html """
                @found "User", -> @message "turn on", "Mobile", ->
                """
            script.attr "type", "text/jumly-sequence-diagram"
            diag = $.jumly.run_script_ script
            diag.find(".interaction:not(.activated)").expect length:1

        it 'should be thrown because no type', ->
            expect(-> $.jumly.run_script_ $ "<script>").toThrow()


