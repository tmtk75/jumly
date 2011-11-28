description "message", ->
    shared_behavior "1 recursive call to right", ->
        given "2 objects, obj_a, obj_b", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: 88
                height: 33
            )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                width: 88
                height: 33
            ))
            diagram.appendTo $("body")
            obj_a.find(".name").html "obj-a"
            obj_b.find(".name").html "obj-b"
            $(".occurrence", diagram).css 
                width: 12
                "border-width": 0
            
            obj_b.activate().interact(obj_a).toward().interact obj_b
        
        when_it "refering some elements", ->
            @ll_b0 = $.uml($(".occurrence:eq(0)", diagram))[0]
            @ll_a1 = $.uml($(".occurrence:eq(1)", diagram))[0]
            @ll_b2 = $.uml($(".occurrence:eq(2)", diagram))[0]
            @msg1st = $.uml($(".message", diagram)[0])[0]
            @msg2nd = $.uml($(".message", diagram)[1])[0]
            diagram.find(".message").css "z-index", "100"
        
        and_ "composing", ->
            diagram.compose()
    
    shared_behavior "3 recursive calls to right", ->
        it_behaves_as "1 recursive call to right"
        when_it "interacting twice from the last", ->
            $.uml($(".interaction:last", diagram))[0]
                .toward().interact(obj_a).toward().interact obj_b
        
        and_ "refering new elements", ->
            @ll_a3 = $.uml($(".occurrence:eq(3)", diagram))[0]
            @ll_b4 = $.uml($(".occurrence:eq(4)", diagram))[0]
            @msg3rd = $.uml($(".message", diagram)[2])[0]
            @msg4th = $.uml($(".message", diagram)[3])[0]
            diagram.find(".message").css "z-index", "100"
        
        and_ "composing", ->
            diagram.compose()
    
    scenario "guarantee '3 recursive calls to right' for mesasge to right", ->
        it_behaves_as "3 recursive calls to right"
        when_it "calculating line of msg4th", ->
            @a = msg4th.to_line($(""))
        
        then_it "the message is up to ll_b4.left", ->
            a.dst.x.shouldBe ll_b4.offset().left - msg4th.offset().left
    
    shared_behavior "3 objects and 3 lost messages", ->
        given "3 objects", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: 88
                height: 33
            )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                width: 88
                height: 33
            )).append(@obj_c = $.uml(".object").offset(left: 250).css(
                width: 88
                height: 33
            ))
            diagram.appendTo $("body")
        
        when_it "message lost from each of objects", ->
            obj_a.lost()
            obj_b.lost()
            obj_c.lost()
        
        and_ "compose", ->
            diagram.compose()
    
    scenario "lost-message is at left side of the next object from the origin object", ->
        it_behaves_as "3 objects and 3 lost messages"
        then_it "object compsition", ->
            diagram.appendTo $ "body"
            diagram
                .find("> .object-lane").expect(length: 1)
                    .find("> .object").expect(length: 3)
                    .end()
                .end()
                .find("> .lifeline").expect(length: 3)
                .end()
                .find("> .activated.interaction > .occurrence > .lost.interaction").expect(length: 3)
    
    scenario "position of lost-message", ->
        it_behaves_as "3 objects and 3 lost messages"
        then_it ".icon:eq(0) which has .icon class is left at the next object", ->
        
        and_ ".icon:eq(1) which has .icon class is left at the next object", ->
        
        and_ ".icon:eq(2) is right at the object object", ->
    
    shared_behavior "left message b/w 2 objects(obj_a, obj_b)", ->
        given "2 objects, obj_a, obj_b", ->
            @OBJ_W = 88
            @LL_W = 10
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: OBJ_W
                height: 33
            )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                width: OBJ_W
                height: 33
            ))
            diagram.appendTo $("body")
            obj_a.find(".name").html "obj-a"
            obj_b.find(".name").html "obj-b"
            $(".occurrence", diagram).css 
                width: LL_W
                "border-width": 0
        
        when_it "interacting", ->
            obj_b.activate().interact obj_a
        
        and_ "refering some elements", ->
            @ll_b = $.uml($(".occurrence:eq(0)", diagram))[0]
            @ll_a = $.uml($(".occurrence:eq(1)", diagram))[0]
            @msg1st = $.uml($(".message", diagram)[0])[0]
        
        and_ "composing", ->
            diagram.compose()
    
    scenario "a basic arrow length and start/end point", ->
        it_behaves_as "left message b/w 2 objects(obj_a, obj_b)"
        when_it "refering a message", ->
            @a = msg1st.to_line($(""))
        
        then_it "message left fit to the source occurrence's left on global coordinate", ->
            msg1st.offset().left.shouldBe ll_a.offset().left
        
        and_ "message right fit to the destination occurrence's right on global coordinate", ->
            msg1st.right().shouldBe ll_b.right()
        
        then_it "start point of arrow is left of source occurrence on local coordinate", ->
            a.src.x.shouldBe ll_b.offset().left - msg1st.offset().left
        
        and_ "end point of arrow is right of destination occurrence on local coordinate", ->
            a.dst.x.shouldBe ll_a.offset().left + ll_a.outerWidth() - msg1st.offset().left
    
    shared_behavior "1 recursive call to left", ->
        given "2 objects, obj_a, obj_b", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: 88
                height: 33
            )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                width: 88
                height: 33
            ))
            diagram.appendTo $("body")
            obj_a.html "obj-a"
            obj_b.html "obj-b"
            $(".occurrence", diagram).css 
                width: 12
                "border-width": 0
            
            obj_a.activate().interact(obj_b).toward().interact obj_a
        
        when_it "refering some elements", ->
            @ll_a0 = $.uml($(".occurrence:eq(0)", diagram))[0]
            @ll_b1 = $.uml($(".occurrence:eq(1)", diagram))[0]
            @ll_a2 = $.uml($(".occurrence:eq(2)", diagram))[0]
            @msg1st = $.uml($(".message", diagram)[0])[0]
            @msg2nd = $.uml($(".message", diagram)[1])[0]
            diagram.find(".message").css "z-index", "100"
        
        and_ "composing", ->
            diagram.compose()
    
    scenario "guarantee '1 recursive call to left' for message to right", ->
        it_behaves_as "1 recursive call to left"
        when_it "calculating line of msg2nd", ->
            @a = msg2nd.to_line($(""))
        
        then_it "the message is up to ll_a2.left", ->
            a.dst.x.shouldBe ll_a2.outerWidth()
    
    shared_behavior "3 recursive calls to left", ->
        it_behaves_as "1 recursive call to left"
        when_it "interacting twice from the last", ->
            $.uml($(".interaction:last", diagram))[0].toward().interact(obj_b).toward().interact obj_a
        
        and_ "refering new elements", ->
            @ll_b3 = $.uml($(".occurrence:eq(3)", diagram))[0]
            @ll_a4 = $.uml($(".occurrence:eq(4)", diagram))[0]
            @msg3rd = $.uml($(".message", diagram)[2])[0]
            @msg4th = $.uml($(".message", diagram)[3])[0]
            diagram.find(".message").css "z-index", "100"
        
        and_ "composing", ->
            diagram.compose()
    
    scenario "guarantee '3 recursive calls to left' for mesasge to right", ->
        it_behaves_as "3 recursive calls to left"
        when_it "calculating line of msg4th", ->
            @a = msg4th.to_line($(""))
        
        then_it "the message is up to ll_a4.left", ->
            a.dst.x.shouldBe ll_a4.outerWidth()
    
    choose = (obj, func) ->
        for p of obj
            continue  unless obj.hasOwnProperty(p)
            func p, obj
    
    normalize = (params, func) ->
        pivot = {}
        choose params, (p) ->
            pivot[p] = params[p].slice(0)
        
        choose params, (p) ->
            v = pivot[p]
            e = null
            while e = v.shift()
                choose params, (q) ->
                    return  if p == q
        
        ->
    
    params =
        border: [ "left", "right" ]
        width: [ "1px", "3px", "10px" ]
        of: [ "src", "dst" ]
    
    scenario "border of left/right of occurrence is thicker than others", normalize(params, (that) ->
        it_behaves_as "left message b/w 2 objects(obj_a, obj_b)"
        given "occurrences", ->
            @lls =
                src: ll_a
                dst: ll_b
        
        and_ "giving " + that.border + " " + that.width, ->
            lls[that.of].css "border-" + that.border + "-width", that.width
        
        when_ "composing", ->
            diagram.compose()
        
        and_ "length of line for the message", ->
            @a = msg1st.to_line($(""))
        
        then_ "for dst.x, " + that, ->
            a.dst.x.shouldBe ll_a.outerWidth()
        
        and_ "for src.x, " + that, ->
            a.src.x.shouldBe ll_b.offset().left - ll_a.offset().left
    )


    description "return-message, recursive-call, destroy-message, lost-message", ->
        shared_behavior "3 interactions", ->
            given "3 objects, obj_a, obj_b, obj_c", ->
                @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                    width: 88
                    height: 31
                )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                    width: 88
                    height: 31
                )).append(@obj_c = $.uml(".object").offset(left: 250).css(
                    width: 88
                    height: 31
                ))
                diagram.appendTo $("body")
                obj_a.activate()
                          .interact(obj_b).reply()
                          .toward().interact(obj_c).reply()
            when_it "compose", ->
                diagram.compose()
        
        scenario "guarantee '3 interactions'", ->
            it_behaves_as "3 interactions"
            when_it "refer", ->
                @retmsg0 = $.uml($(".return", diagram)[0])[0]
                @retmsg1 = $.uml($(".return", diagram)[1])[0]
            then_it "bottom of 1 return is above top of 2nd return", ->
                #(retmsg0.offset().top + retmsg0.outerHeight()).shouldBeLessThan retmsg1.offset().top
            
            and_ "interaction has .reply", ->
                diagram.$0(".interaction:eq(1)").hasClass("reply").shouldBe true
            
            and_ "too", ->
                diagram.$0(".interaction:eq(2)").hasClass("reply").shouldBe true
        
        shared_behavior "3 level recursive call", ->
            given "2 objects, obj_a, obj_b", ->
                @diagram = $.uml(".sequence-diagram")
                            .append(@obj_a = $.uml(".object").offset(left: 50)
                                              .css(width: 88, height: 31))
                diagram.appendTo $("body")
                obj_a.activate()
                     .interact(obj_a)
                     .toward().interact(obj_a)
                              .toward().interact(obj_a)
            
            when_it "compose", ->
                @diagram.css("font-size":"100%")  ##WORKAROUND to fix
                @diagram.compose()
        
        scenario "guarantee '3 level recursive call'", ->
            it_behaves_as "3 level recursive call"
            when_it "", ->
                @c0 = $("canvas:eq(0)", diagram)
                @c1 = $("canvas:eq(1)", diagram)
                @c2 = $("canvas:eq(2)", diagram)
            
            ## NOTE: GOOD:@r1464, Bad:@r1465
            then_it "bottom of c0 < top of c1", ->
                (c0.offset().top + c0.outerHeight() <= c1.offset().top).shouldBe true
            
            then_it "bottom of c0 < top of c2", ->
                (c0.offset().top + c0.outerHeight() <= c2.offset().top).shouldBe true
        
        narrative "destroy"

        shared_behavior "a destroy", ->
            given "2 objects", ->
                @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                    width: 88
                    height: 31
                )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                    width: 88
                    height: 31
                ))
                diagram.appendTo $("body")
            
            when_it "destroy", ->
                @occurr = obj_a.activate().destroy(obj_b)
            
            and_ "compose", ->
                diagram.compose()
        
        scenario "guarantee 'a destroy' for DOM composition", ->
            it_behaves_as "a destroy"
            then_it "it has .stop node", ->
                diagram.find(".stop").length.shouldBe 1
            
            and_ "ensure composition", ->
                diagram.find("> .object-lane").expect().lengthIs(1)
                       .end()
                       .find("> .lifeline").expect().lengthIs(2)
                           .find("> .line").expect().lengthIs(2)
                           .end()
                       .end()
                       .find("> .interaction").expect().lengthIs(1)
                           .find("> .occurrence").expect().lengthIs(1)
                               .find("> .interaction").expect().lengthIs(1)
                                   .find("> .message").expect().lengthIs(1)
                                   .end()
                                   .find("> .occurrence").expect().lengthIs(1)
                                   .end()
                                   .find("> .stop").expect().lengthIs 1
        
        scenario "guarantee 'a destroy' for position", ->
            it_behaves_as "a destroy"
            then_it "stop-icon is at the center of the lifeline", ->
            
            and_ "stop-icon is just below the occurrence", ->
        
        narrative "lost"

        shared_behavior "lost message", ->
            given "3 objects", ->
                @diagram = $.uml(".sequence-diagram")
                            .append(@obj_a = $.uml(".object", "A"))
                            .append(@obj_b = $.uml(".object", "B"))
                            .append(@obj_c = $.uml(".object", "C"))
                            .find(".object").css(width: 88, height: 31).end()
                diagram.appendTo $("body")
            
            when_it "message lost", ->
                @iact_a = obj_a.activate().interact(null, stereotype: ".lost")
        
        scenario "guarantee 'lost message' for to_line", ->
            it_behaves_as "lost message"
            when_it "compose", ->
                diagram.compose()
            
            when_it "to_line runs", ->
                @lostmsg = diagram.$0(".lost .message")
                @a = lostmsg.to_line($(".message canvas"))
            
            then_it "to_line work well for src", ->
                a.src.x.shouldBeGreaterThan 0
            
            and_ "dst", ->
                (a.dst.x + lostmsg.offset().left).shouldBe diagram.find(".object").mostLeftRight().right
        
        scenario "guarantee 'lost message' for composition and left", ->
            it_behaves_as "lost message"
            when_it "compose", ->
                diagram.compose()
            
            then_it "lost message is at the mostright.", ->
                (obj_c.offset().left + obj_c.outerWidth() - 1).shouldBe iact_a.find(".icon").offset().left
            
            then_it "the composition is as following", ->
                diagram
                    .find("> .object-lane").expect().lengthIs(1)
                    .end()
                    .find("> .lifeline").expect().lengthIs(3)
                    .end()
                    .find("> .interaction").expect().lengthIs(1)
                        .find("> .occurrence").expect().lengthIs(1)
                            .find("> .lost").expect().lengthIs(1)
                                .find("> .message").expect().lengthIs(1)
                                .end()
                                .find("> .icon").expect().lengthIs 1
        
        shared_behavior "to test return-message for 3 objects and 2 interactions", ->
            given "a snapshot", ->
                @diagram = $.uml(".sequence-diagram")
                            .append(@customer    = $.uml(".object").css(left: 50 + 150 * 0).html("Customer"))
                            .append(@order       = $.uml(".object").css(left: 50 + 150 * 1).html("Order"))
                            .append(@menumanager = $.uml(".object").css(left: 50 + 150 * 2).html("Menu Manager"))
                            .find(".object").width(100).height(33).end()
                diagram.appendTo $("body")
                customer.activate()
                        .interact(menumanager)
                        .toward().interact(order).reply()
            
            when_it "composing", ->
                diagram.compose()
        
        scenario "guarantee 'to test return-message for 3 objects and 2 interactions'", ->
            it_behaves_as "to test return-message for 3 objects and 2 interactions"
            then_it "3 lifelines are generated", ->
                diagram.find(".lifeline").length.shouldBe 3
            
            and_ "3 interactions are existed", ->
                diagram.find(".interaction").length.shouldBe 3

    description "self-calling two times", ->
        scenario "parallelly", ->
            given "two interactions", ->
                @diag = $.uml(".sequence-diagram")
                         .append(@obj_a = $.uml ".object")
                obj_a.activate()
                     .interact(obj_a)
                     .awayfrom().interact(obj_a)
            when_it "compose", ->
                $("body").append diag
                diag.compose()
            then_it "actor/actee are same", ->
                diag
                  .find("> .interaction.activated")
                    .find("> .occurrence")
                      .find("> .interaction:eq(0)")
                        .find("> .occurrence").end().end()
                      .find("> .interaction:eq(1)").expect (e) ->
                          n = $.uml(e)[0].data "uml:this"
                          n.find(".message").outerBottom().shouldBeLessThan n.find(".occurrence").outerBottom()
                          e = n.gives ".object"
                          e.as(".actor") is e.as(".actee")
        scenario "nest", ->
            given "two interactions", ->
                @diag = $.uml(".sequence-diagram")
                         .append(@obj_a = $.uml ".object")
                obj_a.activate()
                     .interact(obj_a)
                     .toward().interact(obj_a)
            when_it "compose", ->
                $("body").append diag
                diag.compose()
            then_it "actor/actee are same", ->
                diag
                  .find("> .interaction.activated")
                    .find("> .occurrence")
                      .find("> .interaction")
                        .find("> .occurrence").end().end()
                          .find("> .interaction").expect (e) ->
                              n = $.uml(e)[0].data "uml:this"
                              n.find(".message").outerBottom().shouldBeLessThan n.find(".occurrence").outerBottom()
                              e = n.gives ".object"
                              e.as(".actor") is e.as(".actee")
        scenario "next an usual message", ->
            given "two interactions", ->
                @diag = $.uml(".sequence-diagram")
                         .append(@obj_a = $.uml ".object")
                         .append(@obj_b = $.uml ".object")
                obj_a.activate()
                     .interact(obj_b)
                     .awayfrom().interact(obj_a)
            when_it "compose", ->
                $("body").append diag
                diag.compose()
            then_it "actor/actee are same", ->
                diag
                  .find("> .interaction.activated")
                    .find("> .occurrence")
                      .find("> .interaction:eq(0)")
                        .find("> .occurrence").end().end()
                      .find("> .interaction:eq(1)").expect (e) ->
                          n = $.uml(e)[0].data "uml:this"
                          n.find(".message").outerBottom().shouldBeLessThan n.find(".occurrence").outerBottom()
                          e = n.gives ".object"
                          e.as(".actor") is e.as(".actee")
        scenario "next an usual message and nest", ->
            given "three interactions", ->
                @diag = $.uml(".sequence-diagram")
                         .append(@obj_a = $.uml ".object")
                         .append(@obj_b = $.uml ".object")
                obj_a.activate()
                     .interact(obj_b)
                     .awayfrom().interact(obj_a)
                                .toward().interact(obj_a)
            when_it "compose", ->
                $("body").append diag
                diag.css("font-size":"100%")  ##WORKAROUND to fix
                diag.compose()
            then_it "not be overlapped", ->
                diag
                  .find("> .interaction.activated")
                    .find("> .occurrence")
                      .find("> .interaction:eq(0)")
                        .find("> .occurrence").end().end()
                      .find("> .interaction:eq(1)")
                        .find("> .occurrence")
                          .find("> .interaction").expect (e) ->
                                m0 = $ $(e).parents(".interaction:eq(0)").find(".message:eq(0)")
                                m1 = $(e).find(".message:eq(0)")
                                a = m0.outerBottom()
                                b = m1.offset().top
                                a < b and a > 0 and b > 0
    description "create", ->
        scenario "creation in the flow", ->
            given "a .object", ->
                @diag = $.uml ".sequence-diagram"
                diag.append(@obj = $.uml ".object", name:"Customer")
            when_it "create an order", ->
                @iact = obj.activate()
                           .create name:"Order", id:"newone"
                #diag.debugshow()
            then_it "an new object is created", ->
                diag.find(".object").length.shouldBe 2
            and_ ->
                (iact.gives(".object").as(".actor") is obj).shouldBe true
            then_it "an new interaction is created", ->
                diag.find(".interaction").not(".activated").length.shouldBe 1
            then_it "should be Order for the name of object", ->
                diag.newone.name().shouldBe 'Order'
            then_it "should be as a property of diag", ->
                (diag.newone is diag.find("#newone").data("uml:this")).shouldBe true
            then_it "should has id", ->
                (diag.find("#newone").data("uml:this") is iact.gives(".occurrence").as(".actee").gives(".object")).shouldBe true

        shared_scenario "sync-self-call", ->
            given "an .object", ->
                @diag = $.uml ".sequence-diagram"
                diag.append(@obj = $.uml ".object", name:"a")
            when_it "call ownself in sync", ->
                @iact = obj.activate()
                   .interact(obj)
            when_it "compose", ->
                diag.appendTo $ "body"
                diag.compose()
            then_it "number of top level interaction is 1", ->
                diag.find("> .interaction > .occurrence > .interaction").length.shouldBe 1
            then_it "child occurrence exists", ->
                @child = diag.find("> .interaction > .occurrence > .interaction > .occurrence")
                @child.length.shouldBe 1
            then_it "destination occurrence is on the top occurrence", ->
                @child.data("uml:this").isOnOccurrence().shouldBe true

        scenario "async-self-call", ->
            it_behaves_as "sync-self-call"
            when_it "call ownself in async", ->
                iact.stereotype("asynchronous")
            when_it "compose", ->
                diag.appendTo $ "body"
                diag.compose()
            then_it "inner occurrence will be replaced out to 1-level higher", ->
                diag.find("> .interaction").length.shouldBe 2
            then_it "has a special class, .activated", ->
                diag.find("> .interaction:eq(1)").hasClass("activated").shouldBe true
            then_it "has a special class, .asynchronous", ->
                diag.find("> .interaction:eq(1)").hasClass("asynchronous").shouldBe true
            then_it "destination occurrence is not on the top occurrence because of async", ->
                @occurr = diag.find("> .interaction:eq(1) > .occurrence").data("uml:this")
                @occurr.isOnOccurrence().shouldBe false

    scenario "creation just after found", ->
        given "", ->
            @diag = $.uml(".sequence-diagram")
            diag.appendTo $ "body"
            diag.found "A", ->
                @create "C"
            diag.compose()
        then_it "works", ->

