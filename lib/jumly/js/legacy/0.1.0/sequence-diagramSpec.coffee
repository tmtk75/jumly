u = $.jumly
description "sequence-diagram", ->

    description "width", ->

        scenario "of single object, which is includeing the horizontal thickness of box-shadow", ->
            given "an object", ->
                @diag = u ".sequence-diagram"
                @diag.css border:"black solid 1px"
                @ctxt = diag.found "Something"
            when_it "give shadow and compose", ->
                $(["", "-webkit-", "-moz-", "-o-"]).each (i, e) -> diag.find(".object").css(e + "box-shadow", "10px 5px 5px #080")
                ctxt.compose $ "body"
            then_it "including the thickness of shadow", ->
                a = diag.width()
                b = diag.find(".object").width()
                a.shouldBeGreaterThan b
            
        
    shared_behavior "create two objects", ->
        given "two objects -- a, b", ->
            $.extend jQuery::,
                left: ->
                    @offset().left
                
                hcenter: ->
                    @offset().left + @width() / 2
                
                left_is_in: (r) ->
                    r[0] < @left() and @left() < r[1]
            
            @_in_ = (a, x, b) ->
                a < x and x < b
            
            @a = $.jumly(".object")
            @b = $.jumly(".object")
    
    shared_behavior "activate a", ->
        it_behaves_as "create two objects"
        when_it "activate one", ->
            @occurrence_a = a.activate()
    
    scenario "guarantee 'activation a'", ->
        it_behaves_as "activate a"
        then_it "occurrence.owner returns a", ->
            (occurrence_a.gives(".object") == a).shouldBe true
        
        and_ "the occurrence is not on a occurrence", ->
            (not occurrence_a.isOnOccurrence()).shouldBe true
        
        and_ "parent occurrence is null", ->
            (occurrence_a.parentOccurrence() == null).shouldBe true
    
    shared_behavior "a interacts to b", ->
        it_behaves_as "activate a"
        when_it "interact with another and returns an interaction", ->
            @iact_a_b = occurrence_a.interact(b)
    
    scenario "guarantee 'a interacts to b'", ->
        it_behaves_as "a interacts to b"
        then_it "the interaction has a occurrence of the actor", ->
            (iact_a_b.gives(".occurrence").as(".actor") == occurrence_a).shouldBe true
        
        and_ "the owner of the actor's occurrence equal to a", ->
            (iact_a_b.gives(".occurrence").as(".actor").gives(".object") == a).shouldBe true
        
        and_ "the owner of the actee's occurrence equal to b", ->
            (iact_a_b.gives(".occurrence").as(".actee").gives(".object") == b).shouldBe true
        
        and_ "the interaction is not to itself", ->
            iact_a_b.is_to_itself().shouldBe false
    
    shared_behavior "interacting among 3 objects", ->
        it_behaves_as "a interacts to b"
        given "a new object -- c", ->
            @c = $.jumly(".object")
        
        when_it "interacting from the occurrence of b to c", ->
            @iact_b_c = iact_a_b.gives(".occurrence").as(".actee").interact(c)
    
    scenario "guarantee 'interacting among 3 objects'", ->
        it_behaves_as "interacting among 3 objects"
        then_it "the 2nd interaction has the occurrence for c", ->
            (iact_b_c.gives(".occurrence").as(".actee").gives(".object") == c).shouldBe true
        
        and_ "the new interaction has the occurrence for b, too", ->
            (iact_b_c.gives(".occurrence").as(".actor").gives(".object") == b).shouldBe true
    
    shared_behavior "interacting back to a from c over b", ->
        it_behaves_as "interacting among 3 objects"
        when_it "interacting from c to a", ->
            @iact_c_a = iact_b_c.gives(".occurrence").as(".actor").interact(a)
    
    scenario "guarantee 'interacting back to a from c over b'", ->
        it_behaves_as "interacting back to a from c over b"
        then_it "the new interaction has the lineline for a", ->
            (iact_c_a.gives(".occurrence").as(".actee").gives(".object") == a).shouldBe true
        
        and_ "it differs to the 1st occurrence for a", ->
            (iact_c_a.gives(".occurrence").as(".actee") != occurrence_a).shouldBe true
    
    shared_behavior "message to itself for a", ->
        when_it "interacting to itself", ->
            @iact_a_a = iact_c_a.gives(".occurrence").as(".actee").interact(a)
    
    scenario "guarantee 'message to itself for a'", ->
        it_behaves_as "message to itself for a"
        then_it "owner of both occurrence is same", ->
            (iact_a_a.gives(".occurrence").as(".actor").gives(".object") == iact_a_a.gives(".occurrence").as(".actee").gives(".object")).shouldBe true
        
        but_ "occurrence instance are not same", ->
            (iact_a_a.gives(".occurrence").as(".actor") != iact_a_a.gives(".occurrence").as(".actee")).shouldBe true
        
        and_ "the interaction.itself is true", ->
            iact_a_a.is_to_itself().shouldBe true
    
    description "sequence diagram DOM structure", ->
    
    scenario "a sequence starts from an unknown event source", ->
        given "an object", ->
            @obj_a = $.jumly(".object")
        
        when_it "the soruce interacts to the object", ->
            @ll_a = obj_a.activate()
        
        then_it "the occurrence is contained in an interaction", ->
            @iact = $.jumly(ll_a.parents(".interaction"))[0]
            iact.length.shouldBe 1
        
        and_ "the source object for the interaction is null", ->
            (iact.gives(".occurrence").as(".actor") == null).shouldBe true
        
        but_ "isn't undefined", ->
            (iact.gives(".occurrence").as(".actor") != undefined).shouldBe true
        
        and_ "the interaction having the occurrence contains 1 occurrence", ->
            iact.find(".occurrence").length.shouldBe 1
        
        and_ "the destination object for the interaction is the activated object", ->
            (iact.gives(".occurrence").as(".actee").gives(".object") == obj_a).shouldBe true
    
    shared_behavior "create an object and activate it", ->
        given "a sequence-diagram", ->
            @diagram = $.jumly(".sequence-diagram")
        
        and_ "an object", ->
            @obj_a = $.jumly(".object")
        
        when_it "add the object into the diagram", ->
            diagram.append obj_a
        
        and_ "the .object is activated and a occurrence is generated", ->
            @ll_a = obj_a.activate()
    
    scenario "guarantee 'create an object and activate it'", ->
        it_behaves_as "create an object and activate it"
        then_it "an interaction to the object is contained by the diagram", ->
            $("> .interaction", diagram).length.shouldBe 1
        
        and_ "a occurrence are contained by the diagram", ->
            $("> .interaction .occurrence", diagram).length.shouldBe 1
        
        and_ "the occurrence doesn't have any interaction", ->
            $("> .interaction .occurrence .interaction", diagram).length.shouldBe 0
    
    shared_behavior "create two objects, activate one of them and interact b/w 2", ->
        it_behaves_as "create an object and activate it"
        given "2nd object", ->
            @obj_b = $.jumly(".object")
        
        and_ "add the both into the diagram", ->
            diagram.append obj_b
        
        when_it "interacts to another one", ->
            @iact_a_b = ll_a.interact(obj_b)
    
    scenario "guarantee 'create two objects, activate one of them and interact b/w 2'", ->
        it_behaves_as "create two objects, activate one of them and interact b/w 2"
        then_it "there is an interaction just under the diagram", ->
            $("> .interaction", diagram).length.shouldBe 1
        
        and_ "there are two interactions in the diagram", ->
            $(".interaction", diagram).length.shouldBe 2
        
        and_ "the occurrence has already been contained in the diagram", ->
            $("> .interaction .occurrence", diagram).length.shouldBe 2
        
        and_ "there is a message in the interaction", ->
            $("> .interaction .message", diagram).length.shouldBe 1
        
        and_ "the total number of interactions", ->
            $.jumly($(".interaction", diagram)).length.shouldBe 2
        
        and_ "the number of interactions under occurrence", ->
            $.jumly($(".occurrence .interaction", diagram)).length.shouldBe 1
    
    scenario "guarantee DOM structure of 'create an object and activate it'", ->
        it_behaves_as "create an object and activate it"
        then_it "object = 1", ->
            diagram.find("> .object").length.shouldBe 1
        
        and_ "interaction = 1", ->
            diagram.find("> .interaction").length.shouldBe 1
        
        and_ "occurrence = 1", ->
            diagram.find("> .interaction > .occurrence").length.shouldBe 1
        
        and_ "message = 0", ->
            diagram.find("> .message").length.shouldBe 0
        
        and_ "diagram, object", ->
            diagram.find("> :eq(0)").hasClass("object").shouldBe true
        
        and_ "diagram, interaction", ->
            diagram.find("> :eq(1)").hasClass("interaction").shouldBe true
        
        and_ "diagram, occurrence", ->
            diagram.find("> .interaction > :eq(0)").hasClass("occurrence").shouldBe true
    
    scenario "guarantee DOM composition of 'create an object and activate it' by YAML", ->
        it_behaves_as "create an object and activate it"
        then_it "The diagram has 2 children, .object and .interaction, and the interaction has a occurrence", ->
            diagram.find("> .object").expect().lengthIs(1).end().find("> .interaction").expect().lengthIs(1).find("> .occurrence").expect().lengthIs 1
    
    scenario "guarantee DOM composition of 'create two objects, activate one of them and interact b/w 2'", ->
        it_behaves_as "create two objects, activate one of them and interact b/w 2"
        then_it "the composition below", ->
            diagram.find("> .object:eq(0)").expect().lengthIs(1).end().find("> .interaction").expect().lengthIs(1).find("> .occurrence").expect().lengthIs(1).find("> .interaction").expect().lengthIs(1).find("> .message").expect().lengthIs(1).end().find("> .occurrence").expect().lengthIs(1).end().end().end().end().find("> .object:eq(1)").expect().lengthIs 1
    
    scenario "valid occurrences", ->
        given "a diagram and 3 objects", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object")).append(@obj_b = $.jumly(".object")).append(@obj_c = $.jumly(".object"))
        
        when_it "activating an object of two", ->
            @ll_a = obj_a.activate()
        
        and_ "obj_a interact to obj_b", ->
            @iact_a_b = ll_a.interact(obj_b)
            @ll_b = iact_a_b.gives(".occurrence").as(".actee")
        
        and_ "obj_b interact to obj_c", ->
            @iact_b_c = ll_b.interact(obj_c)
            @ll_c = iact_b_c.gives(".occurrence").as(".actee")
        
        and_ "selecting interactions under occurrence", ->
            @iacts = $.jumly($(".occurrence .interaction", diagram))
        
        then_it "ll_a has the diagram as the parent", ->
            ll_a.parents(".diagram").length.shouldBe 1
        
        then_it "number of interactions is 2", ->
            (iacts.length == 2).shouldBe true
        
        and_ "the 1st is iact_a_b", ->
            (iacts[0] == iact_a_b).shouldBe true
        
        and_ "the 2nd is iact_b_c", ->
            (iacts[1] == iact_b_c).shouldBe true
        
        and_ "the 1st has ll_a", ->
            (iacts[0].gives(".occurrence").as(".actor") == ll_a).shouldBe true
        
        and_ "ll_b", ->
            (iacts[0].gives(".occurrence").as(".actee") == ll_b).shouldBe true
        
        and_ "the 2nd has ll_b", ->
            (iacts[1].gives(".occurrence").as(".actor") == ll_b).shouldBe true
        
        and_ "ll_c", ->
            (iacts[1].gives(".occurrence").as(".actee") == ll_c).shouldBe true
    
    description "sequence diagram CSS (left, top) width x height for each element", ->
    
    shared_behavior "size and location of occurrence to right", ->
        it_behaves_as "create two objects, activate one of them and interact b/w 2"
        given "the diagram appended into body", ->
            $("body").append diagram
        
        and_ "get the occurrence of obj_b", ->
            @ll_b = iact_a_b.gives(".occurrence").as(".actee")
        
        and_ "get the width of ll_a", ->
            @w_ll_a = ll_a.width()
        
        and_ "get the width of ll_b", ->
            @w_ll_b = parseFloat(ll_b.css("width"))
        
        when_it "set width of all objects 100", ->
            $(".object", diagram).css 
                width: 100
                height: 33
        
        and_ "move obj_b to 150px", ->
            obj_b.offset left: 150
        
        and_ "move occurrences to 0", ->
            $(".occurrence", diagram).offset left: 0
        
        and_ "compose occurrences", ->
            diagram.compose()
        
        and_ "get x of ll_a", ->
            @x_ll_a = ll_a.offset().left
        
        and_ "get x of ll_b", ->
            @x_ll_b = ll_b.offset().left
    
    scenario "guarantee 'size and location of occurrence to right'", ->
        it_behaves_as "size and location of occurrence to right"
        then_it "has a body as the parent", ->
            ll_a.parents("body").length.shouldBe 1
        
        then_it "width of ll_a is greater than 0", ->
            ll_a.width().shouldBeGreaterThan 0
        
        then_it "width of ll_a is greater than 0", ->
            w_ll_a.shouldBeGreaterThan 0
        
        and_ "width of ll_b is greater than 0", ->
            w_ll_b.shouldBeGreaterThan 0
        
        and_ "x of ll_a is greater than 0", ->
            x_ll_a.shouldBeGreaterThan 0
        
        and_ "x of ll_a is less than the center of obj_a", ->
            x_ll_a.shouldBeLessThan obj_a.offset().left + obj_a.width() / 2
        
        and_ "x of ll_b is greater than x of obj_b", ->
            x_ll_b.shouldBeGreaterThan obj_b.offset().left
        
        and_ "x of ll_b is less than the center of obj_b", ->
            x_ll_b.shouldBeLessThan obj_b.offset().left + obj_b.width() / 2
        
        and_ "message is toward right", ->
            diagram.$(".message")[0].isTowardRight().shouldBe true
        
        then_it "ll_a.width() > 0", ->
            (ll_a.width() > 0).shouldBe true
        
        and_ "ll_b.width() > 0", ->
            (ll_b.width() > 0).shouldBe true
        
        and_ "obj_a.left() < ll_a.left() < obj_a.hcenter()", ->
            (obj_a.left() < ll_a.left() and ll_a.left() < obj_a.hcenter()).shouldBe true
        
        and_ "obj_b.left() < ll_b.left() < obj_b.hcenter()", ->
            (obj_b.left() < ll_b.left() and ll_b.left() < obj_b.hcenter()).shouldBe true
        
        and_ "ll_a.left() is in [obj_a.left(), obj_a.hcenter()]", ->
            ll_a.left_is_in([ obj_a.left(), obj_a.hcenter() ]).shouldBe true
        
        and_ "ll_b.left() is in [obj_b.left(), obj_a.hcenter()]", ->
            ll_b.left_is_in([ obj_b.left(), obj_b.hcenter() ]).shouldBe true
        
        and_ "_in_(obj_a.left(), ll_a.left(), obj_a.hcenter())", ->
            _in_(obj_a.left(), ll_a.left(), obj_a.hcenter()).shouldBe true
        
        and_ "_in_(obj_b.left(), ll_b.left(), obj_b.hcenter())", ->
            _in_(obj_b.left(), ll_b.left(), obj_b.hcenter()).shouldBe true
    
    shared_behavior "a right message from obj_b to obj_c", ->
        it_behaves_as "size and location of occurrence to right"
        given "a new object which size is 100", ->
            @obj_c = $.jumly(".object").css(
                width: 100
                height: 33
            )
        
        when_it "appending the object into the diagram", ->
            diagram.append obj_c
        
        and_ "move obj_c to 300", ->
            obj_c.offset left: 300
        
        and_ "obj_b interact to obj_c", ->
            @ll_c = ll_b.interact(obj_c).gives(".occurrence").as(".actee")
        
        and_ "compose occurrences", ->
            diagram.compose()
    
    scenario "guarantee 'a right message from obj_b to obj_c'", ->
        it_behaves_as "a right message from obj_b to obj_c"
        then_it "obj_c.left() < ll_c.left() < obj_c.hcenter()", ->
            (obj_c.left() < ll_c.left() and ll_c.left() < obj_c.hcenter()).shouldBe true
        
        and_ "2nd message is toward right", ->
            diagram.$(".message")[1].isTowardRight().shouldBe true
    
    scenario "horizontal positional relation", ->
        given "3 objects", ->
            @a = $.jumly(".object").offset(
                left: 0
                top: 0
            )
            @b = $.jumly(".object").offset(
                left: 100
                top: 0
            )
            @c = $.jumly(".object").offset(
                left: 200
                top: 0
            )
            @diagram = $.jumly(".sequence-diagram").append(a).append(b).append(c)
            $(".object", diagram).width 88
            $("body").append diagram
        
        then_it "a is left at b", ->
            a.isLeftAt(b).shouldBe true
        
        then_it "b is left at c", ->
            b.isLeftAt(c).shouldBe true
        
        then_it "a is left at c", ->
            a.isLeftAt(c).shouldBe true
        
        then_it "b is right at a", ->
            b.isRightAt(a).shouldBe true
        
        then_it "c is right at b", ->
            c.isRightAt(b).shouldBe true
        
        then_it "c is right at a", ->
            c.isRightAt(a).shouldBe true
        
        then_it "a is not left at a(itself)", ->
            (not a.isLeftAt(a)).shouldBe true
        
        then_it "a is not right at a(itself)", ->
            (not a.isRightAt(a)).shouldBe true
    
    shared_behavior "message is sent back from obj_c", ->
        it_behaves_as "a right message from obj_b to obj_c"
        when_it "obj_c interact from ll_c to obj_b", ->
            @ll_b2 = ll_c.interact(obj_b).gives(".occurrence").as(".actee")
        
        and_ "doing re-location", ->
            diagram.compose()
    
    scenario "guarantee 'message is sent back from obj_c", ->
        it_behaves_as "message is sent back from obj_c"
        then_it "obj_b.left() < ll_b2.left()", ->
            obj_b.left().shouldBeLessThan ll_b2.left()
        
        then_it "ll_b2.left() < obj_b.hcenter()", ->
            ll_b2.left().shouldBeEqual obj_b.hcenter()
        
        and_ "1st message is toward right", ->
            diagram.$(".message")[0].isTowardRight().shouldBe true
        
        and_ "2nd message is toward right", ->
            diagram.$(".message")[1].isTowardRight().shouldBe true
        
        and_ "3rd message is toward left", ->
            diagram.$(".message")[2].isTowardLeft().shouldBe true
        
        and_ "ll_b2 is on ll_b", ->
            ll_b2.isOnOccurrence().shouldBe true
        
        and_ "ll_b is a parent occurrence for ll_b2", ->
            (ll_b2.parentOccurrence() == ll_b).shouldBe true
        
        and_ "ll_b doesn't shift", ->
            ll_b.shiftToParent().shouldBe 0
        
        and_ "ll_b2 shifts toward right", ->
            ll_b2.shiftToParent().shouldBe 1
    
    scenario "guarantee 'message is sent back from obj_b to obj_a", ->
        when_it "obj_b interact from ll_b2 to obj_a", ->
            @ll_a2 = ll_b2.interact(obj_a).gives(".occurrence").as(".actee")
        
        and_ "doing re-location", ->
            diagram.compose()
        
        then_it "obj_a.left() < ll_a2.left()", ->
            obj_a.left().shouldBeLessThan ll_a2.left()
        
        then_it "ll_a2.left() < obj_a.hcenter()", ->
            ll_a2.left().shouldBeEqual obj_a.hcenter()
        
        and_ "ll_a is a parent occurrence for ll_a2", ->
            (ll_a2.parentOccurrence() == ll_a).shouldBe true
        
        and_ "ll_a2 shifts toward right", ->
            ll_a2.shiftToParent().shouldBe 1
    
    scenario "left message over obj_b back to obj_a", ->
        it_behaves_as "a right message from obj_b to obj_c"
        when_it "obj_c interact from ll_c to obj_b", ->
            @ll_a2 = ll_c.interact(obj_a).gives(".occurrence").as(".actee")
        
        and_ "composing", ->
            diagram.compose()
        
        and_ "refer msg_ca", ->
            @msg_ca = diagram.$(".message:eq(2)")[0]
        
        then_it "obj_a.left() < ll_a2.left()", ->
            obj_a.left().shouldBeLessThan ll_a2.left()
        
        then_it "ll_a2.left() < obj_a.hcenter()", ->
            ll_a2.left().shouldBeEqual obj_a.hcenter()
        
        and_ "left of msg_ca is on the left of ll_c", ->
            a = msg_ca.offset()
            b = ll_a2.offset()
            a.left.shouldBe b.left
        
        and_ "right of msg_ca is on the right of ll_a", ->
            msg_ca.right().shouldBe ll_c.right()
        
        and_ "(optional case) included canvas's width is equal", ->
            msg_ca.find("canvas").width().shouldBe msg_ca.width()
        
        and_ "ll_a is a parent occurrence for ll_a2", ->
            (ll_a2.parentOccurrence() == ll_a).shouldBe true
    
    shared_behavior "4 objects flowing from left to right", ->
        given "a diagram and 4 objects", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").offset(left: 450).css(
                width: 100
                height: 33
            )).append(@obj_b = $.jumly(".object").offset(left: 300).css(
                width: 100
                height: 33
            )).append(@obj_c = $.jumly(".object").offset(left: 150).css(
                width: 100
                height: 33
            )).append(@obj_d = $.jumly(".object").offset(left: 0).css(
                width: 100
                height: 33
            ))
            diagram.appendTo $("body")
        
        when_it "activating an object of two", ->
            @ll_a = obj_a.activate()
        
        and_ "obj_a interact to obj_b", ->
            @ll_b = ll_a.interact(obj_b).gives(".occurrence").as(".actee")
        
        and_ "locating", ->
            diagram.compose()
    
    scenario "guarantee '4 objects flowing from left to right'", ->
        it_behaves_as "4 objects flowing from left to right"
        then_it "obj_b.left() < ll_b.left() < obj_b.hcenter()", ->
            (obj_b.left() < ll_b.left() and ll_b.left() < obj_b.hcenter()).shouldBe true
    
    shared_behavior "a message toward left over an object", ->
        it_behaves_as "4 objects flowing from left to right"
        when_it "obj_b interact to obj_d over obj_c", ->
            @ll_d = ll_b.interact(obj_d).gives(".occurrence").as(".actee")
        
        and_ "relocating", ->
            diagram.compose()
    
    scenario "guarantee 'a message toward left over an object'", ->
        it_behaves_as "a message toward left over an object"
        then_it "obj_d.left() < ll_d.left() < obj_d.hcenter()", ->
            (obj_d.left() < ll_d.left() and ll_d.left() < obj_d.hcenter()).shouldBe true
    
    scenario "a message toward left over an object", ->
        it_behaves_as "a message toward left over an object"
        when_it "obj_d interact to obj_a over obj_c and obj_b", ->
            @ll_a = ll_d.interact(obj_a).gives(".occurrence").as(".actee")
        
        and_ "relocating", ->
            diagram.compose()
        
        then_it "obj_a.left() < ll_a.left() < obj_a.hcenter()", ->
            (obj_a.left() < ll_a.left() and ll_a.left() < obj_a.hcenter()).shouldBe true
    
        and_ "ll_a is on a occurrence", ->
            ll_a.isOnOccurrence().shouldBe true
        
        and_ "ll_a shifts toward left", ->
            (ll_a.shiftToParent() == -1).shouldBe true

    ## Pending because it ignores jquery-ui plugin.
    xscenario "simple definition of width for elements (especially, jQuery position habit)", ->
        given "two objects whose width is 1px", ->
            @a = $.jumly(".object").width(1)
            @b = $.jumly(".object").width(1)
        
        when_it "moving one of them with position() at the right of another", ->
            b.position 
                of: a
                at: "right top"
                my: "left top"
        
        then_it "left of css is shifted to right by 1px", ->
            expect((a.offset().left + 1) + "px").toBe b.css("left")
        
        then_it "left of offset is still equal", ->
            expect(a.offset().left).toBe b.offset().left
        
        then_it "widht of css", ->
            expect("1px").toBe b.css("width")
        
        then_it "widht()", ->
            expect(1).toBe b.width()
    
    shared_behavior "a->b", ->
        given "a->b", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").css(
                left: 0
                width: 50
                height: 33
            )).append(@obj_b = $.jumly(".object").css(
                left: 150
                width: 100
                height: 33
            ))
            diagram.appendTo $("body")
            @iact_ab = obj_a.activate().interact(obj_b)
            @ll_a = diagram.$(".occurrence")[0]
            @ll_b = diagram.$(".occurrence")[1]
            @msg_ab = diagram.$(".message")[0]
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "width of right message depending on the distance b/w 2 objects", ->
        it_behaves_as "a->b"
        then_it "left of msg_ab is on the left of ll_a", ->
            msg_ab.offset().left.shouldBe ll_a.offset().left
        
        and_ "right of msg_ab is on the right of ll_b", ->
            msg_ab.right().shouldBe ll_b.right()
        
        and_ "width of a canvas in the message is equal to message's", ->
            msg_ab.find("canvas").width().shouldBe msg_ab.width()
    
    scenario "relation for height b/w two occurrences on simplest cases", ->
        it_behaves_as "a->b"
        then_it "ll_b.top is at the point 1em far from top toward bottom", ->
            @a = ll_a.offset().top + parseInt(ll_a.css("padding-top")) + parseInt(ll_a.css("border-top-width")) + parseInt(ll_a.css("margin-top"))
            ll_b.offset().top.shouldBe a
        
        and_ "ll_b.bottom is at the point 1em far from bottom toward top", ->
            ll_b.outerBottom().shouldBe ll_a.outerBottom() - parseInt(ll_a.css("padding-bottom")) - parseInt(ll_a.css("border-bottom-width"))
    
    shared_behavior "a<-b", ->
        given "a<-b", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").css(
                left: 16 * 8
                width: 5
                height: 33
            )).append(@obj_b = $.jumly(".object").css(
                left: 16 * 8 + 16 * 2
                width: 10
                height: 33
            ))
            diagram.appendTo $("body")
            @iact_ba = obj_b.activate().interact(obj_a)
            @ll_b = diagram.$(".occurrence")[0]
            @ll_a = diagram.$(".occurrence")[1]
            @msg_ba = diagram.$(".message")[0]
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "width of left message depending on the distance b/w 2 objects", ->
        it_behaves_as "a<-b"
        then_it "left of msg_ba is on the left of ll_a", ->
            msg_ba.offset().left.shouldBe ll_a.offset().left
        
        and_ "right of msg_ba is on the right of ll_b", ->
            msg_ba.right().shouldBe ll_b.right()
        
        and_ "width of a canvas in the message is equal to message's", ->
            msg_ba.find("canvas").width().shouldBe msg_ba.width()
    
    shared_behavior "a->b->c", ->
        it_behaves_as "a->b"
        given "b->c", ->
            diagram.append obj_c = $.jumly(".object").css(
                left: 250
                width: 50
                height: 33
            )
            @iact_bc = ll_b.interact(obj_c)
            @ll_c = iact_bc.gives(".occurrence").as(".actee")
            @msg_bc = $.jumly($(".message", iact_bc))[0]
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "width of 2nd right message", ->
        it_behaves_as "a->b->c"
        then_it "left of msg_bc is on the left of ll_b", ->
            msg_bc.offset().left.shouldBe ll_b.offset().left
        
        and_ "right of msg_bc is on the right of ll_c", ->
            msg_bc.right().shouldBe ll_c.right()
        
        and_ "width of a canvas in the message is equal to message's", ->
            msg_bc.find("canvas").width().shouldBe msg_bc.width()
    
    shared_behavior "c<-a<-b", ->
        it_behaves_as "a<-b"
        given "a->c", ->
            diagram.append obj_c = $.jumly(".object").css(
                left: 16 * 6
                width: 4
                height: 33
            )
            @iact_ac = ll_a.interact(obj_c)
            @ll_c = iact_ac.gives(".occurrence").as(".actee")
            @msg_ac = $.jumly($(".message", iact_ac))[0]
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "width of 2nd left message", ->
        it_behaves_as "c<-a<-b"
        then_it "left of msg_ac is on the left of ll_c", ->
            msg_ac.offset().left.shouldBe ll_c.offset().left
        
        and_ "right of msg_ac is on the right of ll_a", ->
            msg_ac.right().shouldBe ll_a.right()
        
        and_ "width of a canvas in the message is equal to message's", ->
            msg_ac.find("canvas").width().shouldBe msg_ac.width()
    
    shared_behavior "occurrence right shift", ->
        it_behaves_as "a->b"
        when_it "obj_b interacts obj_a", ->
            @iact_ba = ll_b.interact(obj_a)
            @ll_a2 = iact_ba.gives(".occurrence").as(".actee")
        
        and_ "composing the diagram", ->
            diagram.compose()
    
    scenario "guarantee 'occurrence right shift'", ->
        it_behaves_as "occurrence right shift"
        then_it "the last occurrence shifts toward obj_b (right)", ->
            ll_a2.offset().left.shouldBeGreaterThan ll_a.offset().left
        
        and_ "ll_a.left < the left", ->
            ll_a.offset().left.shouldBeLessThan ll_a2.offset().left
        
        and_ "the left < ll_a.right", ->
            ll_a2.offset().left.shouldBeLessThan ll_a.right()
        
        and_ "ll_a.right < the right", ->
            ll_a.right().shouldBeLessThan ll_a2.right()
    
    scenario "occurrence left shift", ->
        it_behaves_as "a<-b"
        when_it "obj_a interacts obj_b", ->
            @iact_ab = ll_a.interact(obj_b)
            @ll_b2 = iact_ab.gives(".occurrence").as(".actee")
        
        and_ "composing the diagram", ->
            diagram.compose()
        
        then_it "the last occurrence shifts toward obj_a (left)", ->
            ll_b2.offset().left.shouldBeLessThan ll_b.offset().left
        
        and_ "ll_b.left < the right", ->
            ll_b.offset().left.shouldBeLessThan ll_b2.right()
        
        and_ "the right < ll_b.right", ->
            ll_b2.right().shouldBeLessThan ll_b.right()
        
        and_ "the left < ll_b.left", ->
            ll_b2.offset().left.shouldBeLessThan ll_b.offset().left
    
    scenario "ping pong b/w 2 objects", ->
        it_behaves_as "occurrence right shift"
        when_it "interacting 3 times", ->
            ll_a2.interact(obj_b).gives(".occurrence").as(".actee").interact(obj_a).gives(".occurrence").as(".actee").interact(obj_b).gives(".occurrence").as ".actee"
        
        and_ "composing the diagram", ->
            diagram.compose()
        
        and_ "4th occurrence", ->
            @ll3 = diagram.$(".occurrence:eq(3)")[0]
        
        and_ "6th occurrence", ->
            @ll5 = diagram.$(".occurrence:eq(5)")[0]
        
        then_it "there are 6 occurrences", ->
            diagram.$(".occurrence").length.shouldBe 6
        
        and_ "6th occurrence is on the 4th occurrence", ->
            (ll5.parentOccurrence() == ll3).shouldBe true
        
        and_ "6th occurrence is on the left edge of 4th occurrence", ->
            ll5.offset().left.shouldBeLessThan ll3.offset().left
    
    shared_behavior "a->a", ->
        given "a->a", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").css(
                width: 100
                height: 33
            ))
            diagram.appendTo $("body")
            @iact_aa = obj_a.activate().interact(obj_a)
            @ll_a0 = diagram.$(".occurrence")[0]
            @ll_a1 = diagram.$(".occurrence")[1]
            @msg_aa = diagram.$(".message")[0]
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "self invokation without parent occurrence", ->
        it_behaves_as "a->a"
        then_it "a1 is shifted to right for left", ->
            ll_a0.offset().left.shouldBeLessThan ll_a1.offset().left
        
        and_ "a1 is shifted to right for right", ->
            ll_a0.right().shouldBeLessThan ll_a1.right()
        
        and_ "shift sign is positive (to right)", ->
            ll_a1.shiftToParent().shouldBe 1
    
    scenario "self invokation next to left message", ->
        it_behaves_as "a<-b"
        given "a message to itself", ->
            @iact_aa = ll_a.interact(obj_a)
        
        and_ "the occurrence of actee", ->
            @ll_a2 = iact_aa.gives(".occurrence").as(".actee")
        
        and_ "the message to itself", ->
            @msg_aa = $.jumly(iact_aa.find(".message"))[0]
        
        when_it "composing", ->
            diagram.compose()
        
        then_it "ll_a.left < ll_a2.left", ->
            ll_a.offset().left.shouldBeLessThan ll_a2.offset().left
        
        and_ "ll_a.right < ll_a2.right", ->
            ll_a.right().shouldBeLessThan ll_a2.right()
        
        and_ "shift sign is positive (to right)", ->
            ll_a2.shiftToParent().shouldBe 1
        
        and_ "msg.top < actee-occurrence.top", ->
            msg_aa.offset().top.shouldBeLessThan ll_a2.offset().top
        
        and_ "msg.left  == actee-occurrence.left", ->
            msg_aa.offset().left.shouldBe ll_a2.offset().left
        
        and_ "msg.right  > actee-occurrence.right", ->
            msg_aa.right().shouldBeGreaterThan ll_a2.right()
        
        and_ "msg.height > actee-occurrence.height", ->
            msg_aa.outerHeight().shouldBeGreaterThan ll_a2.outerHeight()
        
        and_ "ll_a.bottom > ll_a2.bottom", ->
            (ll_a.outerBottom() - parseInt(ll_a.css("padding-bottom"))).shouldBeGreaterThan ll_a2.outerBottom()
    
    shared_behavior "self invokation next to right message", ->
        it_behaves_as "a->b"
        given "a message to itself", ->
            @iact_bb = ll_b.interact(obj_b)
        
        and_ "the occurrence of actee", ->
            @ll_b2 = iact_bb.gives(".occurrence").as(".actee")
        
        and_ "the message to itself", ->
            @msg_bb = $.jumly(iact_bb.find(".message"))[0]
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "guarantee 'self invokation next to right message'", ->
        it_behaves_as "self invokation next to right message"
        then_it "ll_b.left < ll_b2.left", ->
            ll_b.offset().left.shouldBeLessThan ll_b2.offset().left
        
        and_ "ll_b.right < ll_b2.right", ->
            ll_b.right().shouldBeLessThan ll_b2.right()
        
        and_ "shift sign is negative (to left)", ->
            ll_b2.shiftToParent().shouldBe 1
    
        and_ "msg.top    < actee-occurrence.top", ->
            msg_bb.offset().top.shouldBeLessThan ll_b2.offset().top
        
        and_ "msg.left  == actee-occurrence.left", ->
            msg_bb.offset().left.shouldBe ll_b2.offset().left
        
        and_ "msg.right  > actee-occurrence.right", ->
            msg_bb.right().shouldBeGreaterThan ll_b2.right()
        
        and_ "msg.height > actee-occurrence.height", ->
            msg_bb.outerHeight().shouldBeGreaterThan ll_b2.outerHeight()
    
    scenario "nested self invokation", ->
        it_behaves_as "self invokation next to right message"
        given "a message to itself", ->
            @iact_bb2 = ll_b2.interact(obj_b)
        
        and_ "the occurrence of actee", ->
            @ll_b3 = iact_bb2.gives(".occurrence").as(".actee")
        
        and_ "the message to itself", ->
            @msg_bb3 = $.jumly(iact_bb2.find(".message"))[0]
        
        when_it "composing", ->
            diagram.compose()
        
        then_it "ll_b3.bottom < ll_b2.bottom", ->
            ll_b3.outerBottom().shouldBeLessThan ll_b2.outerBottom()

    description "preferredWidth(legacy scenario)", ->
        scenario "for an object", ->
            given "an object", ->
                @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").width(88))
                diagram.appendTo $("body")
            
            when_it "compose", ->
                diagram.compose()
            
            then_it "the width of diagram is equal to the object's one", ->
                @left = obj_a.offset().left
                diagram.preferredWidth().shouldBe obj_a.outerWidth()
            
            and_ "it's 88px", ->
                diagram.preferredWidth().shouldBe 88
        
        scenario "for two objects", ->
            given "an object", ->
                @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").width(88)).append(@obj_b = $.jumly(".object").width(12))
                diagram.appendTo $("body")
            
            when_it "compose", ->
                diagram.compose()
            
            then_it "it's depending on the most-left-right", ->
                @left = obj_a.offset().left
                diagram.preferredWidth().shouldBe obj_b.right() - obj_a.offset().left + 1

    description "preferredWidth(latest scenario)", ->
        newseqdiag = ->
            diag = $.jumly ".sequence-diagram"
            diag.appendTo $ "body"
            diag
    
        it "should be 0 in case of initial diagram", ->
            diag = newseqdiag()
            diag.compose()
            diag.preferredWidth().shouldBe 0
    
        it "should be the same width to border-width", ->
            diag = newseqdiag()
            diag.css border:"2px black solid"
            diag.compose()
            diag.preferredWidth().shouldBe 2 + 2
    
        it "is same width to inside object", ->
            diag = newseqdiag()
            diag.append obj = ($.jumly ".object", "foobar")
            diag.compose()
            diag.preferredWidth().shouldBe obj.outerWidth()
   
        new2 = ->
            diag = newseqdiag()
            diag.append @a = ($.jumly ".object", "foobar")
            diag.append @b = ($.jumly ".object", "fizbuz")
            diag

        it "is same width to the width of inside objects positioned with css", ->
            diag = new2()
            a.css left:0
            b.css left:200
            diag.compose()
            diag.preferredWidth().shouldBe (0 + 200 + b.outerWidth())
        
        it "is same width to the width of inside objects positioned with offset", ->
            diag = new2()
            a.offset left:0
            b.offset left:200
            diag.compose()
            ##console.log $("body").css("margin-left")
            ## Relative relation is not changed from the above, so it should be same.
            ## But offset take the margin-left of body.
            diag.preferredWidth().shouldBe (0 + 200 + b.outerWidth())
        
        it "is same width to the width of inside objects positioned with offset in the dialog having border", ->
            diag = new2()
            diag.css border:"10px solid gray"
            a.offset left:0
            b.offset left:200
            diag.compose()
            diag.preferredWidth().shouldBe (10 + 0 + 200 + b.outerWidth() + 10)
    
        it "is same width to the inside object", ->
            diag = newseqdiag()
            diag.append (obj = $.jumly ".object")
            diag.compose()
            diag.preferredWidth().shouldBe obj.outerWidth()

        it "is up to browser rendering for height", ->


    description "location of .object when composing", ->
      it 'should be fixed if the value is not "auto"', ->
        diag = $.jumly ".sequence-diagram"
        $("body").append diag
        ctxt = diag.found aaaa111:"A", -> @message "call", "B"
        obj = diag.find(".object:eq(1)")
        obj.offset(left:-123)
        ctxt.compose()
        obj.offset().left.shouldBe -123

      it 'is able to set settings for compose', ->
        MLEFT = 234
        $.jumly.preferences(".sequence-diagram", compose_most_left:MLEFT)
        diag = $.jumly ".sequence-diagram"
        $("body").append diag
        (diag.found aaaa222:"A-able-0", -> @message "call", bbbb222:"B-able-1").compose()
        diag.find(".object:eq(0)").offset().left.shouldBe MLEFT + $("body").cssAsInt("margin-left")

    
    description "de-fact specification", ->
      it "objects identified by the name in sequence-diagram", ->
        diag = $.jumly ".sequence-diagram"
        diag.found "JUMLY service", ->
              @create "Styled Node"
            .compose $ "body"
        expect(diag.find(".object:eq(0)").attr("id")).toBe "jumly-service"
        expect(diag.find(".object:eq(1)").attr("id")).toBe "styled-node"
        expect(diag["jumly_service"]).toBeDefined()
        expect(diag["styled_node"]).toBeDefined()
