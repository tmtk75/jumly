description "interaction", ->
    scenario "create two objects", ->
        given "two objects -- a, b", ->
            @a = jQuery.uml(".object").name("a")
            @b = jQuery.uml(".object").name("b")
            @occurr = a.activate()
            @iact_a_b = occurr.interact(b)
        
        then_it "the interaction has a occurrence of the actor", ->
            iact_a_b.is_to_itself().shouldBe false
        
        then_it "gives for .actor", ->
            expect(iact_a_b.gives(".object").as(".actor")).toBe a
        
        then_it "gives for .actee", ->
            expect(iact_a_b.gives(".object").as(".actee")).toBe b
    
    shared_behavior "simple interaction a->b", ->
        given "an interaction", ->
            @diagram = $.jumly(".sequence-diagram")
                        .append(@obj_a = $.jumly(".object").css(left: 50))
                        .append(@obj_b = $.jumly(".object").css(left: 200))
                        .find(".object").width(100).height(33).end()
            diagram.appendTo $("body")
            @iact_ab = obj_a.activate()
                            .interact(obj_b)
                            .find(".name").html("a->b").end()
        
        when_it "composing", ->
            diagram.compose()
   
    ## xthen_its are too strict as spec, and are disable.
    scenario "centering name to an right message", ->
        it_behaves_as "simple interaction a->b"
        when_it "refering the name", ->
            @a = $(".message .name", diagram)
        
        and_ "canvas", ->
            @b = $(".message canvas", diagram)
        
        xthen_it "left of the canvas < left of the name", ->
            b.offset().left.shouldBeLessThan a.offset().left
        
        xand_ "left of the name < right of the center", ->
            (a.offset().left + a.width() - 1).shouldBeLessThan b.offset().left + b.width() - 1
        
        and_ "bottom of the name is just b/w the upper part of the canvas", ->
            @a0 = a.offset().top + a.height() - 1
            @b1 = b.offset().top
            @b2 = b.offset().top + b.height() / 2 - 1
        
        and_ "b1 < a0", ->
            b1.shouldBeLessThan a0
        
        xand_ "a0 < b2", ->
            a0.shouldBeLessThan b2
    
    scenario "centering name to an left message", ->
        it_behaves_as "simple interaction a->b"
        when_it "refering the name", ->
            @a = $(".message .name", diagram)
        
        and_ "canvas", ->
            @b = $(".message canvas", diagram)
        
        when_it "swapping the position", ->
            obj_a.css left: 200
            obj_b.css left: 50
        
        and_ "replacing the name", ->
            iact_ab.find(".name").html "[b<-a]"
        
        and_ "composing again", ->
            diagram.compose()
        
        xthen_it "left of the canvas < left of the name", ->
            b.offset().left.shouldBeLessThan a.offset().left
        
        xand_ "left of the name < right of the center", ->
            (a.offset().left + a.width() - 1).shouldBeLessThan b.offset().left + b.width() - 1
        
        and_ "bottom of the name is just b/w the upper part of the canvas", ->
            @a0 = a.offset().top + a.height() - 1
            @b1 = b.offset().top
            @b2 = b.offset().top + b.height() / 2 - 1
        
        and_ "b1 < a0", ->
            b1.shouldBeLessThan a0
        
        xand_ "a0 < b2", ->
            a0.shouldBeLessThan b2
        
        and_ "number of lifeline is 2", ->
            diagram.find(".lifeline").length.shouldBe 2
    
    scenario "size for arrow of message", ->
        it_behaves_as "simple interaction a->b"
        when_it "refering the height of the message", ->
            @msg_ab = diagram.$(".message:eq(0)")[0]
            @canvas = msg_ab.find("canvas")
        
        then_it "both width is same for canvas and the container", ->
            msg_ab.width().shouldBe canvas.width()
        
        and_ "both height is same for canvas and the container", ->
            msg_ab.height().shouldBe canvas.height()
    
    shared_behavior "simple return message", ->
        given "a->b", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").css(
                left: 0
                width: 50
                height: 33
            )).append(obj_b = $.jumly(".object").css(
                left: 150
                width: 100
                height: 33
            ))
            diagram.appendTo $("body")
            @iact_ab = obj_a.activate().interact(obj_b)
            @ll_a = diagram.$(".occurrence")[0]
            @ll_b = diagram.$(".occurrence")[1]
            @msg_ab = diagram.$(".message")[0]
        
        when_it "returning back", ->
            iact_ab.reply()
        
        and_ "refering the message", ->
            @retmsg = diagram.$(".return:eq(0)")[0]
    
        and_ "composing", ->
            diagram.compose()
    
    scenario "guarantee 'simple return message' for location", ->
        it_behaves_as "simple return message"
        then_it "there is a return message", ->
            diagram.$(".return").length.shouldBe 1
        
        and_ "there are two messages", ->
            diagram.$(".message").length.shouldBe 2
        
        and_ "y0, y1, m0", ->
            @y0 = retmsg.offset().top
            @y1 = retmsg.offset().top + retmsg.height()
            @m0 = ll_b.outerBottom()
        
        and_ "y0 < m0 for vertical", ->
            y0.shouldBeLessThan m0
        
        and_ "m0 < y1 for vertical", ->
            m0.shouldBeLessThan y1
        
        and_ "left is equal", ->
            retmsg.offset().left.shouldBe msg_ab.offset().left
        
        and_ "width is equal", ->
            retmsg.width().shouldBe msg_ab.width()
        
        and_ "number of lifeline is 2", ->
            diagram.find(".lifeline").length.shouldBe 2
    
    scenario "guarantee 'simple return message' for DOM structure", ->
        it_behaves_as "simple return message"
        then_it "DOM structure is following", ->
            diagram
                .find("> .object-lane")              .expect().lengthIs(1)
                    .find("> .object")               .expect().lengthIs(2)
                    .end()
                .end()
                .find("> .lifeline")                 .expect().lengthIs(2)
                .end()
                .find("> .interaction")              .expect().lengthIs(1)
                    .find("> .occurrence")           .expect().lengthIs(1)
                        .find("> .interaction")      .expect().lengthIs(1)
                            .find("> .message:eq(0)").expect().lengthIs(1)
                                .find("> .arrow")    .expect().lengthIs(1)
                                .end()
                                .find("> .name")     .expect().lengthIs(1)
                                .end()
                            .end()
                        .find("> .occurrence")       .expect().lengthIs(1)
                        .end()
                        .find("> .message:eq(1)")    .expect().lengthIs(1)
                            .find("> .arrow")        .expect().lengthIs(1)
                            .end()
                            .find("> .name")         .expect().lengthIs 1
    
    shared_behavior "location for name of return-message", ->
        it_behaves_as "simple return message"
        when_it "refering horizontal point", ->
            @arrow = retmsg.find(".arrow:eq(0)")
            @name = retmsg.find(".name:eq(0)")
            @rightarrow = leftarrow + arrow.width() - 1
            @rightname = leftname + name.width() - 1
        
        when_it "refering vertical point", ->
            @toparrow = arrow.offset().top
            @topname = name.offset().top
            @bottomarrow = toparrow + arrow.height()
            @bottomname = topname + name.height()
        
        then_it "arrow left < name left", ->
            la.shouldBeLessThan lb
        
        and_ "name right < arrow right", ->
            la.shouldBeLessThan rb
        
        then_it "name top < arrow top", ->
            ta.shouldBeLessThan tb
        
        and_ "name bottom < arrow bottom", ->
            bb.shouldBeLessThan ba
        
        then_it "both of width for msg and arrow is equal", ->
            a.width().shouldBe retmsg.width()
        
        and_ "both of height for msg and arrow is equal", ->
            a.height().shouldBe retmsg.height()
        
        then_it "height of message > 0", ->
            msg_ab.height().shouldBeGreaterThan 0
        
        and_ "height of return-message > 0", ->
            retmsg.height().shouldBeGreaterThan 0
        
        then_it "canvas width is equal to the message width", ->
            arrow.width().shouldBe retmsg.width()
        
        and_ "canvas height is equal to the message height", ->
            arrow.height().shouldBe retmsg.height()
    
    shared_behavior "name of self message", ->
        given "a self message", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").css(left: 50))
            diagram.appendTo($("body")).find(".object").width(100).height(33).end()
            @iact_ab = obj_a.activate().interact(obj_a).find(".name").html("a->a").end()
        
        when_it "composing", ->
            diagram.compose()
        
        and_ "refering", ->
            @msgname = $(".message > .name", diagram)
            @msgarrow = $(".message > .arrow", diagram)
    
    scenario "guarantee 'name of self message'", ->
        it_behaves_as "name of self message"
        then_it ".arrow and .name are equal in offset().top", ->
            msgname.offset().top.shouldBe msgarrow.offset().top
        
        then_it ".arrow right and .name left are equal", ->
            msgname.offset().left.shouldBe msgarrow.offset().left + msgarrow.outerWidth()
    
    scenario "nested self message", ->
        it_behaves_as "name of self message"
        given "a nested message", ->
            iact_ab.gives(".occurrence").as(".actee").interact(obj_a).find(".message > .name").html "a->a2"
        
        when_it "refering", ->
            @msgname = $(".message > .name:last", diagram)
            @msgarrow = $(".message > .arrow:last", diagram)
        
        and_ "composing", ->
            diagram.compose()
        
        then_it ".arrow and .name are equal in offset().top", ->
            msgname.offset().top.shouldBe msgarrow.offset().top
        
        then_it ".arrow right and .name left are equal", ->
            msgname.offset().left.shouldBe msgarrow.offset().left + msgarrow.outerWidth()
    
    description "message flow with gives/as", ->
        shared_behavior "make a diagram and five objects", ->
            given "a diagram and five objects", ->
                @diagram =
                   @diag = $.jumly(".sequence-diagram")
                            .append(@obj_a = $.jumly ".object", "obj-a")
                            .append(@obj_b = $.jumly ".object", "obj-b")
                            .append(@obj_c = $.jumly ".object", "obj-c")
                            .append(@obj_d = $.jumly ".object", "obj-d")
                            .append(@obj_e = $.jumly ".object", "obj-e")
        ###
        Message flow pattern b/w two interactions.
        -------------------------------------------------
          + A. From oneself to another one.
             |a|                    |a|               ((a, b) and c)    a.message(b).message(c)
             | |--->|b|             | |--->|b|        ((a, b) and a)    a.message(b).message(a)
                    | |--->|c|      | |    | |
                           | |      | |<---| |
    
          + B. From oneself to myself, which is the same A in a sense that
               the originator doesn't move.
             |a|
             | |--->|b|      ((a, b) and b)    a.message(b).message(b)
             | |    | |--+
             | |    | |  |
             | |    | |<-+
    
          + C. From previous one to the same one. repeat two times.
             |a|
             | |--->|b|      (a, b) and (a, b)    a.message(b)
             | |    | |                           a.message(b)
             | |--->|_|
             | |
    
          + D. From other one to another one.
             |a|
             | |--->|b|
             |_|    |_|              (a, b) and (c, d)
                         |c|
                         | |--->|d|
                         | |    | |
        ###
        scenario "Pattern A (plain notation)", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages with gives/as for actee", ->
                a = obj_a.activate()
                a.interact(obj_b).name("(a, b):0")
                 .gives(".occurrence").as(".actee")
                 .interact(obj_c).name("(b, c):1")
            then_it "is following composition", ->
                diag
                  .find("> .interaction") .expect(length:1).expect((e) -> e.hasClass "interaction")
                    .find("> .occurrence").expect(length:1)
                      .find("> .interaction").expect(length:1, name:"(a, b):0")
                        .find("> .occurrence").expect(length:1)
                          .find("> .interaction").expect(length:1, name:"(b, c):1")
    
        scenario "Pattern C (plain notation)", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages with gives/as for actor", ->
                a = obj_a.activate()
                a.interact(obj_b).name("(a, b):0")
                 .gives(".occurrence").as(".actor")
                 .interact(obj_b).name("(a, b):1")
            then_it "is following composition", ->
                diag
                  .find("> .interaction") .expect(length:1).expect((e) -> e.hasClass "interaction")
                    .find("> .occurrence").expect(length:1)
                      .find("> .interaction").expect(length:2)
                        .filter(":eq(0)").expect(name:"(a, b):0").end()
                        .filter(":eq(1)").expect(name:"(a, b):1")
        
        scenario "Pattern D (plain notation)", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages", ->
                obj_a.activate().interact(obj_b).name("(a, b):0")
                obj_c.activate().interact(obj_d).name("(c, d):1")
            then_it "is following composition", ->
                diag
                  .find("> .interaction > .occurrence > .interaction").expect(length:2)
                    .filter(":eq(0)").expect(name:"(a, b):0").end()
                    .filter(":eq(1)").expect(name:"(c, d):1")
    
    description "message flow with directional operator for two interactions", ->
        scenario "Pattern A", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages with 'to' given a closure", ->
                a = obj_a.activate()
                a.interact(obj_b).name("(a, b):0")
                 .to (b, a) ->
                    b.interact(obj_c).name("(b, c):1")
            then_it "is following composition", ->
                diag
                  .find("> * > * > * > * > .interaction").expect(length:1, name:"(b, c):1")
    
        scenario "Pattern A, back to myself", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages with 'to' given a closure", ->
                a = obj_a.activate()
                a.interact(obj_b).name("(a, b):0")
                 .to (b, a) ->
                    b.interact(obj_a).name("(b, a):1")
            then_it "is following composition", ->
                diag
                  .find("> * > * > * > * > .interaction").expect(length:1, name:"(b, a):1")
        
        scenario "Pattern B, to myself", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages", ->
                a = obj_a.activate()
                a.interact(obj_b).name("(a, b):0")
                 .to (b, a) ->
                    b.interact(obj_b).name("(b, b):1")
            then_it "is following composition", ->
                diag
                  .find("> * > * > * > * > .interaction").expect(length:1, name:"(b, b):1")
        
        scenario "Pattern C, 2 times", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages from a to b", ->
                obj_a.activate()
                     .interact(obj_b).name("(a, b):0")
                     .to (b, a) ->
                        a.interact(obj_b).name("(a, b):1")
            then_it "is following composition", ->
                diag
                  .find("> * > * > .interaction:eq(1)").expect(length:1, name:"(a, b):1")
        
        scenario "Pattern D, new interaction", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages", ->
                obj_a.activate().interact(obj_b).name("(a, b):0")
                obj_c.activate().interact(obj_d).name("(c, d):1")
            then_it "is following composition", ->
                diag
                  .find("> .interaction > .occurrence > .interaction:eq(1)").expect(length:1, name:"(c, d):1")
    
        scenario "fowardTo returns .actee occurrence", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages", ->
                a = obj_a.activate()
                a.interact(obj_b).name("(a, b):0")
                 .forwardTo().interact(obj_c).name("(b, c):1")
            then_it "is following composition", ->
                diag
                  .find("> * > * > * > * > .interaction").expect(length:1, name:"(b, c):1")
        
        scenario "'backwardTo' returns .actor occurrence", ->
            it_behaves_as "make a diagram and five objects"
            when_it "2 messages", ->
                a = obj_a.activate()
                a.interact(obj_b).name("(a, b):0")
                 .backwardTo().interact(obj_b).name("(a, b):1")
            then_it "is following composition", ->
                diag
                  .find("> * > * > .interaction:eq(1)").expect(length:1, name:"(a, b):1")
    
    description "message flow with directional operator for 3 interactions", ->
        ###
        Message flow pattern among three interactions.
        -------------------------------------------------
        If a last interaction is b/w b & c, what occurrence the next does start from?
          + A. (b, c).actee
             |a|
             | |--->|b|
             | |    | |--->|c|
             | |           | |--->|d|
             | |                  | |
    
          + B. (b, c).actor
             |a|
             | |--->|b|
             | |    | |--->|c|
             | |    | |    | |
             | |    | |-------->|d|
             | |                | |
    
          + C.
             |a| (b, c)'s ancestor of a
             | |--->|b|
             | |    | |--->|c|
             | |           | |
             | |--------------->|d|
                                | |
    
          + D. any object
             |a|
             | |--->|b|
             | |    | |--->|c|
             | |           | |
                                |d|
                    |c|<--------| |
                    | |         | |
        ###
        shared_behavior "five objects and two interactions from a to c", ->
            it_behaves_as "make a diagram and five objects"
            when_it "a to b, b to c", ->
                @iact_bc = obj_a.activate()
                                .interact(obj_b).name("a->b:0")
                                .toward().interact(obj_c).name("b->c:1")
        ###
             |a|
             | |--->|b|
             | |    | |--->|c|
             | |           | |--->|d|
             | |                  | |
        ###
        scenario "continue to interact at that point", ->
            it_behaves_as "five objects and two interactions from a to c"
            when_it "interacting to obj_d", ->
                @iact_cd = iact_bc.toward()
                                  .interact(obj_d).name "c->d:2"
            then_it "is as the composition like", ->
                diagram.find("> .interaction.activated")
                         .find("> .occurrence")
                           .find("> .interaction")
                             .find("> .occurrence")
                               .find("> .interaction")
                                 .find("> .occurrence")
                                   .find("> .interaction").expect(length:1, name:"c->d:2")
                                     .find("> .occurrence").expect(length:1)
        ###
             |a|
             | |--->|b|
             | |    | |--->|c|
             | |    | |    | |
             | |    | |-------->|d|
             | |                | |
        ###
        scenario "backward to the actor of the interact, and from there start to interact", ->
            it_behaves_as "five objects and two interactions from a to c"
            when_it "interacting to obj_d", ->
                @iact_bd = iact_bc.awayfrom()
                                  .interact(obj_d).name "b->d:2"
            then_it "is as the composition like", ->
                diagram.find("> .interaction.activated")
                         .find("> .occurrence")
                           .find("> .interaction").expect(name:"a->b:0")
                             .find("> .occurrence")
                               .find("> .interaction:eq(0)").expect(name:"b->c:1")
                                 .find("> .occurrence")
                                 .end()
                               .end()
                               .find("> .interaction:eq(1)").expect(length:1, name:"b->d:2")
        ###
             |a| (b, c)'s ancestor of a
             | |--->|b|
             | |    | |--->|c|
             | |           | |
             | |--------------->|d|
                                | |
        ###
        scenario "backward to the actor of the interact, and from there start to interact", ->
            it_behaves_as "five objects and two interactions from a to c"
            when_it "interacting to obj_d from nearby occurrence of obj_a", ->
                @iact_ad = iact_bc.awayfrom(obj_a)
                                  .interact(obj_d).name "a->d:2"
            then_it "is as the composition like", ->
                diagram.find("> .interaction.activated")
                         .find("> .occurrence")
                           .find("> .interaction").expect(name:"a->b:0")
                             .find("> .occurrence")
                               .find("> .interaction:eq(0)").expect(name:"b->c:1")
                                 .find("> .occurrence")
                                 .end()
                               .end()
                             .end()
                           .end()
                           .find("> .interaction:eq(1)").expect(length:1, name:"a->d:2")
        ###
             |a|
             | |--->|b|
             | |    | |--->|c|
             | |           | |
                                |d|
                    |c|<--------| |
                    | |         | |
        ###
        scenario "start to activate newly", ->
            it_behaves_as "five objects and two interactions from a to c"
            when_it "interacting to obj_c newly from obj_d", ->
                @iact_dc = iact_bc.awayfrom(obj_d)
                                  .interact(obj_c).name "c<-d:2"
            then_it "is as the composition like", ->
                diagram.find("> .interaction.activated:eq(0)").end()
                       .find("> .interaction.activated:eq(1)")
                         .find("> .occurrence")
                           .find("> .interaction").expect(length:1, name:"c<-d:2")
    
        description "interaction chain", ->
            scenario "can call interaction after interaction", ->
                it_behaves_as "make a diagram and five objects"
                when_it "a->b, a->c", ->
                    obj_a.activate()
                         .interact(obj_b).name("a->b")
                         .interact(obj_c).name("a->c")
                then_it "should create two interactions from a to b/c", ->
                    diagram.find("> .interaction.activated")
                           .find("> .occurrence")
                             .find("> .interaction:eq(0)").expect(name:'a->b')
                               .find("> .occurrence").expect(length:1)
                               .end()
                             .end()
                             .find("> .interaction:eq(1)").expect(name:'a->c')
                               .find("> .occurrence").expect(length:1)
    
            scenario "can call interaction after interaction", ->
                it_behaves_as "make a diagram and five objects"
                when_it "a->b, a->c", ->
                    obj_a.activate()
                         .interact(obj_b).name("a->b")
                         .forward().interact(obj_c).name("b->c")
                then_it "should create two interactions from a to b/c", ->
                    diagram.find("> .interaction.activated")
                           .find("> .occurrence")
                             .find("> .interaction").expect(name:'a->b')
                               .find("> .occurrence").expect(length:1)
                                 .find("> .interaction").expect(name:'b->c')
                                   .find("> .occurrence").expect(length:1)
    
