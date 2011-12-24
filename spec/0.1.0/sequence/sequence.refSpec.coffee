description "sequence.ref", ->

    shared_behavior "2 objects", ->
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
    
    scenario "when ref is alone", ->
        given "a new found", ->
            @diag = $.uml ".sequence-diagram"
            diag.found "A", ->
                @ref "foobar <a href='http://www.yahoo.com'>yahoo</a>"
            diag.appendTo $ "body"
            @ref = diag.find(".ref:last").self()
        when_it "composing", ->
            diag.compose()
        #then_it "object is at the center of the ref", ->
        # NOTE: Not support this case.
        #    @ref.offset().left.shouldBeLessThan diag.A.offset().left
    
    scenario "when activated", ->
      given "a new found", ->
        @diag = $.uml ".sequence-diagram"
        diag.found "A-act-0"
        diag.appendTo $ "body"
        @occurr = diag.find(".occurrence:last").self()
      when_it "composing", ->
        diag.compose()
      then_it "x0 < x1", ->
        @occurr.offset().left.shouldBeLessThan diag.A.offset().left + diag.A.outerWidth()/2

    scenario "default diagram width", ->
        it_behaves_as "2 objects"
        when_it "compose", ->
            diagram.compose()
        
        then_it "the width depends on the positions of the objects", ->
            @mostright_obj_right = 150 + obj_b.outerWidth()
            @mostleft_obj_left = 50
            @gap_left = mostleft_obj_left - diagram.offset().left
            @obj_occupied_width = mostright_obj_right - mostleft_obj_left
            @expectation = gap_left + obj_occupied_width + gap_left
            diagram.preferences().WIDTH.shouldBe expectation
    
    shared_behavior "left message b/w 2 objects with a ref", ->
        it_behaves_as "2 objects"
        when_it "interacting", ->
            @ll_b = obj_b.activate()
            @ll_b.interact obj_a
            @ll_a = obj_a.gives(".lifeline")
        
        and_ "add a ref", ->
            $.uml(".ref", 
                width: ".object"
                buffer: 0
            ).appendTo diagram
        
        and_ "composing", ->
            diagram.compose()
    
    scenario "guarantee 'left message b/w 2 objects with a ref'", ->
        it_behaves_as "left message b/w 2 objects with a ref"
        when_it "refer some properties", ->
            @ref = $(".ref", diagram)
            @ref_pos = ref.offset()
            @ref_left = ref_pos.left
            @ref_right = ref_pos.left + ref.outerWidth() - 1
        
        then_it "ref's left is less than", ->
            obj_a.offset().left.shouldBeLessThan ref_left
        
        and_ "ref's left is less than", ->
            ref_left.shouldBeLessThan obj_a.offset().left + obj_a.outerWidth() - 1
        
        then_it "ref's right is less than", ->
            obj_b.offset().left.shouldBeLessThan ref_right
        
        and_ "ref's right is less than", ->
            ref_right.shouldBeLessThan obj_b.offset().left + obj_b.outerWidth() - 1
    
    scenario "guarantee 'left message b/w 2 objects with a ref' for DOM structure", ->
        it_behaves_as "2 objects"
        it_behaves_as "left message b/w 2 objects with a ref"
        then_it "DOM structure is following", ->
            diagram.find(".object-lane:eq(0)").expectLengthIs(1)
                   .find(".object:eq(0)").expectLengthIs(1).end()
                   .find(".object:eq(1)").expectLengthIs(1).end()
                   .find(".object:eq(2)").expectLengthIs(0).end().end()
                   .find(".lifeline:eq(0)").expectLengthIs(1).end()
                   .find(".lifeline:eq(1)").expectLengthIs(1).end()
                   .find(".lifeline:eq(2)").expect().lengthIs(0).end()
                   .find(".interaction:eq(0)").expect().lengthIs(1).end()
                   .find(".interaction:eq(1)").expect().lengthIs(1)
                   .find(".occurrence:eq(0)").expect().lengthIs(1).end().end()
                   .find(".ref:eq(0)").expect().lengthIs(1)
                   .find(".header:eq(0)").expect().lengthIs(1)
                   .find(".tag:eq(0)").expect().lengthIs(1).end().end().find(".name:eq(0)").expect().lengthIs(1).end()
                   .find(".name:eq(1)").expect().lengthIs(0).end()
                   .find(".ref:eq(1)").expect().lengthIs 0
    
    narrative "DOM structure for .object"
    shared_behavior "create an object to ensure DOM structure", ->
        given "an object", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: 88
                height: 33
            ))
            diagram.appendTo $("body")
    
    scenario "guarantee 'create an object to ensure DOM structure' just after the creation", ->
        it_behaves_as "create an object to ensure DOM structure"
        then_it "DOM structure is following", ->
            diagram.find(".object:eq(0)").expect().existing().find(".name:eq(0)").expect().existing()
    
    scenario "iconify for .object", ->
        it_behaves_as "create an object to ensure DOM structure"
        when_it "iconify", ->
            obj_a.iconify()
        
        then_it "DOM structure is following", ->
            diagram.find(".object").expect().existing().find(".icon").expect().existing().end().find(".name").expect().existing()
    
    narrative "fragment"
    shared_behavior "3 objects and 2 interactions", ->
        given "3 objects and 2 interactions", ->
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
            obj_a.activate().interact(obj_b).gives(".occurrence").as(".actee").interact obj_c
    
    scenario "guarantee '3 objects and 2 interactions' for 1st interaction", ->
        it_behaves_as "3 objects and 2 interactions"
        when_it "fragment 2nd interaction", ->
            $.uml(".fragment").enclose diagram.find(".interaction:eq(1)")
            diagram.compose().prepend "1st interaction"
        
        and_ "refer", ->
            @ll = $(".occurrence:last", diagram)
            @fragment = $(".fragment", diagram)
        
        then_it ".fragment exists", ->
            diagram.find(".fragment").length.shouldBe 1
        
        and_ "ensure DOM structure -A", ->
            diagram
                .find(".object-lane").expect().lengthIs(1).end()
                .find(".lifeline").expect().lengthIs(3).end()
                .find(".interaction:eq(0)").expect().lengthIs(1)
                .find(".occurrence:eq(0)").expect().lengthIs(1)
                .find(".fragment:eq(0)").expect().lengthIs(1)
                .find(".header:eq(0)").expect().lengthIs(1).end()
                .find(".interaction:eq(0)").expect().lengthIs(1)
                .find(".message:eq(0)").expect().lengthIs(1).end()
                .find(".occurrence:eq(0)").expect().lengthIs(1)
                .find(".interaction:eq(0)").expect().lengthIs(1)
                .find(".message:eq(0)").expect().lengthIs(1).end()
                .find(".occurrence:eq(0)").expect().lengthIs 1
        
        and_ "right of the last .occurrence < right of fragment", ->
            (ll.offset().left + ll.outerWidth()).shouldBeLessThan fragment.offset().left + fragment.outerWidth()
    
    scenario "guarantee '3 objects and 2 interactions' for 2nd interaction", ->
        it_behaves_as "3 objects and 2 interactions"
        when_it "fragment 3rd interaction", ->
            $.uml(".fragment").enclose diagram.find(".interaction:eq(2)")
            diagram.compose().prepend "2nd interaction"
        
        and_ "refer", ->
            @ll = $(".occurrence:last", diagram)
            @fragment = $(".fragment", diagram)
        
        then_it ".fragment exists", ->
            diagram.find(".fragment").length.shouldBe 1
        
        and_ "ensure DOM structure -B", ->
            diagram
                .find(".object-lane").expect().lengthIs(1).end()
                .find(".lifeline").expect().lengthIs(3).end()
                .find("> .interaction").expect().lengthIs(1)
                .find("> .occurrence").expect().lengthIs(1)
                .find("> .interaction").expect().lengthIs(1)
                .find("> .message").expect().lengthIs(1).end()
                .find("> .occurrence").expect().lengthIs(1)
                .find("> .fragment").expect().lengthIs(1)
                .find("> .header").expect().lengthIs(1).end()
                .find("> .interaction").expect().lengthIs(1)
                .find("> .message").expect().lengthIs(1).end().find("> .occurrence").expect().lengthIs 1
        
        and_ "right of the last .occurrence < right of fragment", ->
            (ll.offset().left + ll.outerWidth()).shouldBeLessThan fragment.offset().left + fragment.outerWidth()

    scenario "ref's width depends on the rectangle occupied with objects", ->
      it_behaves_as "2 objects"
      when_it "objects and ref", ->
        diagram.append(@ref = $.uml(".ref", 
            width: ".object"
            buffer: 0
        ).find(".name").html("ref").end()).compose()
      then_it "maybe less than", ->
        ref.outerWidth().shouldBeLessThan $(".object", diagram).mostLeftRight().width()
      then_it "should be centered. left of ref is at left of the center of obj-a", ->
        obj = diagram.find(".object:eq(0)")
        m = obj.offset().left + obj.outerWidth()/2
        ref.offset().left.shouldBeLessThan m
    
    scenario "ref's width in case of no occurrence", ->
        it_behaves_as "2 objects"
        when_it "objects and ref", ->
            diagram.append(@ref = $.uml(".ref").find(".name").html("a ref").end()).compose()
        
        then_it "the width depends on the gap of the lines", ->
            ref.outerWidth().shouldBeGreaterThan $(".line", diagram).mostLeftRight().width()
        then_it "it's not less than twice of diagram width", ->
            ref.outerWidth().shouldBeLessThan $(".object", diagram).mostLeftRight().width()*2
    
    scenario "fragment return", ->
        given "an interaction", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: 88
                height: 31
            )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                width: 88
                height: 31
            ))
            diagram.appendTo $("body")
            @iact_ab = obj_a.activate().interact(obj_b)
        
        when_it "fragment it", ->
            @frag_ab = iact_ab.fragment()
        
        then_it "fragment() returns .fragment", ->
            frag_ab.hasClass("fragment").shouldBe true
        
        xand_ "end() returns the interaction", ->
            frag_ab.end().hasClass("interaction").shouldBe true
        
        xand_ "the instance is iact_ab", ->
            (frag_ab.end() == iact_ab).shouldBe true
    
    shared_behavior "fragment position in a node", ->
        given "3 interactions toward right", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object", "a")).append(@obj_b = $.uml(".object", "b"))
            diagram.appendTo $("body")
            obj_a.activate().interact(obj_b).gives(".occurrence").as(".actor").interact(obj_b).gives(".occurrence").as(".actor").interact(obj_b).gives(".occurrence").as ".actor"
    
    scenario "guarantee 'fragment position in a node' for an interaction", ->
        it_behaves_as "fragment position in a node"
        when_it "", ->
            diagram.$0(".interaction:eq(2)").fragment()
            diagram.append "an interaction"
        
        when_it "compose", ->
            diagram.compose()
        
        then_it "", ->
            diagram
                .find("> .object-lane").expect().lengthIs(1).end()
                .find("> .lifeline").expect().lengthIs(2).end()
                .find("> .interaction").expect().lengthIs(1)
                .find("> .occurrence").expect().lengthIs(1)
                .find("> .interaction:eq(0)").expect().lengthIs(1).end()
                .find("> .fragment").expect().lengthIs(1)
                .find("> .header").expect().lengthIs(1).end()
                .find("> .interaction").expect().lengthIs(1).end()
                .find("> .interaction:eq(1)").expect().lengthIs 0
    
    scenario "guarantee 'fragment position in a node' wrapping two interactions", ->
        it_behaves_as "fragment position in a node"
        when_it "", ->
            diagram.find("> .interaction").find(".interaction:eq(0), .interaction:eq(1)").self().fragment()
            diagram.append "two interactions"
        
        when_it "compose", ->
            diagram.compose()
        
        then_it "", ->
            diagram
                .find("> .object-lane").expect().lengthIs(1).end()
                .find("> .lifeline").expect().lengthIs(2).end()
                .find("> .interaction").expect().lengthIs(1)
                .find("> .occurrence").expect().lengthIs(1)
                .find("> .fragment").expect().lengthIs(1)
                .find("> .header").expect().lengthIs(1).end()
                .find("> .interaction").expect().lengthIs(1).end()
                .find("> .interaction").expect().lengthIs 1
    
    scenario "fragment wrapping left interaction", ->
        given "left interaction wrapped by a fragment", ->
            @diagram = $.uml(".sequence-diagram").append(obj_b = $.uml(".object", "b")).append(obj_a = $.uml(".object", "a"))
            diagram.appendTo $("body")
            obj_a.activate().interact(obj_b).gives(".occurrence").as ".actor"
            @iter = diagram.find(".interaction:eq(1)")
            @iter = iter.self()
            iter.fragment()
            diagram.compose()
        
        then_it "fragment left is left than the interaction on global", ->
            diagram
                .find(".fragment").offset().left.shouldBe diagram
                .find(".interaction:eq(1) .message").offset().left

    description "specific case for ref width", ->

        it "should look good even on the top", ->
            diag = $.jumly ".sequence-diagram"
            ctxt = diag.found "You", ->
                @message "contact", "Me", ->
                    @message "mail", "Him", ->
                @ref "Make the report"
                @ref "Submit it"
            ctxt.compose $ "body"

            you = diag.find(".object:eq(0)").css("border-color", "red")
            obj = diag.find(".object:last")
            
            ref = diag.find(".ref:eq(0)")
            you.offset().left.shouldBeLessThan ref.offset().left
            ref.outerRight().shouldBeLessThan obj.outerRight()

            ref = diag.find(".ref:eq(1)")
            you.offset().left.shouldBeLessThan ref.offset().left
            ref.outerRight().shouldBeLessThan obj.outerRight()

        it "should look good even in the deep", ->
          diag = $.jumly ".sequence-diagram"
          ctxt = diag.found "You-ref-0", ->
            @message "contact", "Me-ref-1", ->
              @message "mail", "Him-ref-2", ->
              @ref "Make the report-ref-3"
              @ref "Submit it-ref-4"
          ctxt.compose $ "body"

          occur = diag.find(".occurrence:eq(0)")
          ref = diag.find(".ref")
          obj = diag.find(".object:last")

          occur.outerRight().shouldBeLessThan ref.offset().left
          ref.outerRight().shouldBeLessThan obj.outerRight()

          occur1 = diag.find(".occurrence:eq(1)")
          occur2 = diag.find(".occurrence:eq(2)")
          ref.offset().left.shouldBeLessThan occur1.offset().left
          occur2.outerRight().shouldBeLessThan ref.outerRight()


        it "should look good even after loop fragment", ->
          diag = $.jumly ".sequence-diagram"
          ctxt = diag.found "You-ref-5", ->
            @message "contact", "Me-ref-6", ->
              @loop @message "mail", "Him-ref-7", ->
                @message "read-ref-8", ->
                @reply "reply", "Me-ref-9"
              @ref "Make the report-ref-10"
          ctxt.compose $ "body"

          occur = diag.find(".occurrence:eq(0)").css("border-color", "red")
          ref = diag.find(".ref")
          obj = diag.find(".object:last")

          occur.outerRight().shouldBeLessThan ref.offset().left
          ref.outerRight().shouldBeLessThan obj.outerRight()
