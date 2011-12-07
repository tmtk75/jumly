description "fragment", ->
    shared_behavior "2 objects(obj_a, obj_b)", ->
        given "2 objects, obj_a, obj_b", ->
            @diagram = $.uml(".sequence-diagram")
                        .append(@obj_a = $.uml(".object").offset(left: 50).css(width: 88, height: 33))
                        .append(@obj_b = $.uml(".object").offset(left: 150).css(width: 88, height: 34))
            diagram.appendTo $("body")
            obj_a.find(".name").html "obj-a"
            obj_b.find(".name").html "obj-b"
    
    shared_behavior "2 objects(obj_a, obj_b) activation(ll_a, iact_ab)", ->
        when_it "one of two(obj_a) interacts to another one(obj_b)", ->
            @ll_a = obj_a.activate()
            @iact_ab = ll_a.interact(obj_b)
    
    scenario "guarantee '2 objects(obj_a, obj_b) activation(ll_a, iact_ab)'", ->
        it_behaves_as "2 objects(obj_a, obj_b)"
        it_behaves_as "2 objects(obj_a, obj_b) activation(ll_a, iact_ab)"
        then_it "the number of occurrence is 2", ->
            diagram.$(".occurrence").length.shouldBe 2
        
        and_ "the number of interaction is 2", ->
            diagram.$(".interaction").length.shouldBe 2
        
        and_ "the 1st child of the diagram is a .occurrence", ->
    
    scenario "2 activations", ->
        it_behaves_as "2 objects(obj_a, obj_b)"
        it_behaves_as "2 objects(obj_a, obj_b) activation(ll_a, iact_ab)"
        when_it "obj_b sends return-message, it ends 1st activation", ->
            iact_ab.reply()
        
        and_ "obj_b activates next", ->
            @ll_b = obj_b.activate()
        
        and_ "interacting to obj_a", ->
            @iact_ba = ll_b.interact(obj_a)
        
        and_ "composing", ->
            diagram.compose()
        
        then_it "the bottom of occurrence for obj_a fits to the top of occurrence for obj_b", ->
            (ll_a.outerBottom() + parseInt(ll_b.css("margin-top")) + 1).shouldBe ll_b.offset().top
        
        and_ "the diagram has 2 interactions", ->
            diagram.find("> .interaction").length.shouldBe 2
    
    shared_behavior "fragment over an interaction", ->
        it_behaves_as "2 objects(obj_a, obj_b)"
        it_behaves_as "2 objects(obj_a, obj_b) activation(ll_a, iact_ab)"
        when_it "fragment", ->
            @fragment = $.uml(".fragment").enclose($("> .interaction:eq(0)", diagram))
        
        and_ "composing", ->
            diagram.compose()
    
    scenario "guarantee 'fragment over an interaction'", ->
        it_behaves_as "fragment over an interaction"
        when_it "add a class to the fragment element", ->
            diagram.$(".fragment:eq(0)")[0].addClass "abcd"
        
        then_it "the number of fragment is 1", ->
            diagram.$(".fragment").length.shouldBe 1
        
        and_ "the number of interaction is 2", ->
            diagram.$(".interaction").length.shouldBe 2
        
        and_ "the number of occurrence is 2", ->
            diagram.$(".occurrence").length.shouldBe 2
        
        and_ "the fragment has a class 'abcd'", ->
            $(".fragment:eq(0)", diagram).hasClass("abcd").shouldBe true
    
    scenario "guarantee 'fragment over an interaction' for DOM structure", ->
        it_behaves_as "fragment over an interaction"
        then_it "following DOM tree is provided", ->
            diagram.find("> .object-lane").expect().lengthIs(1).find("> .object").expect().lengthIs(2).end().end().find("> .lifeline").expect().lengthIs(2).end().find("> .fragment").expect().lengthIs(1).find("> .header").expect().lengthIs(1).find("> .name").expect().lengthIs(1).end().find("> .condition").expect().lengthIs(1).end().end().find("> .interaction").expect().lengthIs(1).find("> .occurrence").expect().lengthIs(1).find("> .interaction").expect().lengthIs(1).find("> .message").expect().lengthIs(1).end().find("> .occurrence").expect().lengthIs 1
    
    scenario "guarantee 'fragment over an interaction' for geometory", ->
        it_behaves_as "fragment over an interaction"
        when_it "refering elements", ->
            @ll_b = iact_ab.gives(".occurrence").as(".actee")
            @fragment_ab = diagram.$(".fragment:eq(0)")[0]
        
        then_it "ll_a is occurrence", ->
            ll_a.hasClass("occurrence").shouldBe true
        
        and_ "ll_b is occurrence", ->
            ll_b.hasClass("occurrence").shouldBe true
        
        then_it "fragment.top < ll_a.top", ->
            fragment_ab.offset().top.shouldBeLessThan ll_a.offset().top
        
        and_ "fragment.top < ll_b.top", ->
            fragment_ab.offset().top.shouldBeLessThan ll_b.offset().top
        
        and_ "ll_a.top < ll_b.top", ->
            ll_a.offset().top.shouldBeLessThan ll_b.offset().top
        
        then_it "ll_a.bottom < fragment.bottom", ->
            ll_a.outerBottom().shouldBeLessThan fragment_ab.outerBottom()
        
        and_ "ll_b.bottom < ll_a.bottom", ->
            ll_b.outerBottom().shouldBeLessThan ll_a.outerBottom()
        
        then_it "fragment.left < ll_a.left", ->
            fragment_ab.offset().left.shouldBeLessThan ll_a.offset().left
        
        and_ "ll_a.left < ll_b.left", ->
            ll_a.offset().left.shouldBeLessThan ll_b.offset().left
        
        then_it "ll_b.right < fragment.right", ->
            ll_b.right().shouldBeLessThan fragment_ab.right()
        
        and_ "ll_a.right < ll_b.right", ->
            ll_a.right().shouldBeLessThan ll_b.right()
    
    shared_behavior "fragment over two interactions", ->
        it_behaves_as "2 objects(obj_a, obj_b)"
        it_behaves_as "2 objects(obj_a, obj_b) activation(ll_a, iact_ab)"
        when_it "interacting again", ->
            obj_a.activate().interact obj_b
        
        and_ "put them in fragment (if you'd like to enclose more than 2 interactions)", ->
            $.uml(".fragment").enclose $("> .interaction", diagram)
        
        and_ "composing", ->
            diagram.compose()
    
    scenario "guarantee 'fragment over two interactions'", ->
        it_behaves_as "fragment over two interactions"
        then_it "the number of interaction is 4 because of twice activation", ->
            diagram.$(".interaction").length.shouldBe 4
        
        and_ "the number of fragment is 1", ->
            diagram.$(".fragment").length.shouldBe 1
        
        and_ "2 interactions are enclosed by the fragment", ->
            diagram.$(".fragment > .interaction").length.shouldBe 2
    
    scenario "guarantee 'fragment over two interaction' for DOM structure", ->
        it_behaves_as "fragment over two interactions"
        then_it "following DOM tree is provided", ->
            diagram.find("> .object-lane").expect().lengthIs(1).find("> .object").expect().lengthIs(2).end().end().find("> .lifeline").expect().lengthIs(2).end().find("> .fragment").expect().lengthIs(1).find("> .header").expect().lengthIs(1).find("> .name").expect().lengthIs(1).end().find("> .condition").expect().lengthIs(1).end().end().find("> .interaction:eq(0)").expect().lengthIs(1).find("> .occurrence").expect().lengthIs(1).find("> .interaction").expect().lengthIs(1).find("> .message").expect().lengthIs(1).end().find("> .occurrence").expect().lengthIs(1).end().end().end().end().find("> .interaction:eq(1)").expect().lengthIs(1).find("> .occurrence").expect().lengthIs(1).find("> .interaction").expect().lengthIs(1).find("> .message").expect().lengthIs(1).end().find("> .occurrence").expect().lengthIs 1
    
    scenario "enclose throws exception when empty array is given", ->
        given "a fragment", ->
            @fragment = $.uml(".fragment")
        
        then_it "throwing an exception", ->
            expect(->
                fragment.enclose []
            ).toThrow jasmine.Matchers.Any(String)
    
    scenario "enclose returns itself", ->
        it_behaves_as "fragment over two interactions"
        given "a fragment", ->
            @fragment = $.uml(".fragment")
        
        when_it "", ->
            @iter = $(".interaction:eq(0)", diagram)
            @frag = fragment.enclose(iter)
        
        then_it "enclose return an object having fragment class", ->
            iter.parent().hasClass("fragment").shouldBe true
        
        and_ "", ->
            (frag == fragment).shouldBe true
    
    shared_behavior "fragment replaces interaction and the identification", ->
        it_behaves_as "2 objects(obj_a, obj_b)"
        it_behaves_as "2 objects(obj_a, obj_b) activation(ll_a, iact_ab)"
        when_it "refering the parent of iact_ab", ->
            @_parent = $.uml(iact_ab.parent())[0]
        
        and_ "apply fragment into iact_ab", ->
            @fragment_ab = $.uml(".fragment").enclose(iact_ab)
        
        and_ "refers the root of fragment", ->
            @diag = fragment_ab.parents(".diagram")[0]
            @fragment_ab_ances = $.uml(diag)[0]
    
    scenario "guarantee 'fragment replaces interaction and the identification' for the fragment parent", ->
        it_behaves_as "fragment replaces interaction and the identification"
        then_it "it's a valid instance", ->
            (_parent != null).shouldBe true
        
        and_ "also too", ->
            (fragment_ab != null).shouldBe true
        
        and_ "it is same to the original parent of iact_ab", ->
            ($.uml(fragment_ab.parent())[0] == _parent).shouldBe true
    
    scenario "guarantee 'fragment replaces interaction and the identification' for the fragment ancestor", ->
        it_behaves_as "fragment replaces interaction and the identification"
        then_it "the ancestor is the diagram", ->
            (fragment_ab_ances[0] == diagram[0]).shouldBe true
        
        and_ "it has .diagram as the ancestor", ->
            (fragment_ab_ances[0] != undefined).shouldBe true
        
        and_ "is enable to reach to the fragment from the diagram", ->
            (diagram.$(".fragment")[0] == fragment_ab).shouldBe true
    
    scenario "horizontal geometory for fragment", ->
        it_behaves_as "fragment over an interaction"
        when_it "refering elements", ->
            @fragment_ab = diagram.$(".fragment:eq(0)")[0]
        
        then_it "the left of fragment < left of leftmost obj_a", ->
            fragment_ab.offset().left.shouldBeLessThan obj_a.offset().left
    
    scenario "nested fragment horizontal relation", ->
        given "2 interactions", ->
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
            @fragment_0 = $.uml(".fragment").enclose(diagram.find(".interaction:eq(0)"))
            @fragment_1 = $.uml(".fragment").enclose(diagram.find(".interaction:eq(1)"))
            @fragment_2 = $.uml(".fragment").enclose(diagram.find(".interaction:eq(2)"))
            diagram.compose()

    describe "misc", ->
        scenario "syntax error happens on UMLFragment::enclose", ->
            given "a diagram and 2 objects", ->
                @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                    width: 88
                    height: 33
                )).append(@obj_b = $.uml(".object").offset(left: 150).css(
                    width: 88
                    height: 34
                ))
                diagram.appendTo $("body")
            
            when_it "activating", ->
                @ll_a = obj_a.activate()
                @iact_ab = ll_a.interact(obj_b)
            
            and_ ->
                obj_a.activate().interact obj_b
                diagram.compose()
            
            and_ ->
                @iters = $("> .interaction", diagram)
                $.uml(".fragment").enclose iters
            
            then_it "", ->

    scenario "expanding width left/right horizontally", ->
        given "an fragment in an interaction", ->
            $("html").addClass $.client.os
            @diagram = $.uml(".sequence-diagram")
                       .append(customer = $.uml ".object", "Customer")
                       .append(order = $.uml ".object", "Order")
                       .append(menumanager = $.uml ".object", "Menu Manager")
                       .append(database = $.uml ".object", "Database")
                       .appendTo($ "body").self()
          
            customer.activate().interact(order).name("End Order")
                .toward().interact(menumanager).name("")
                    .toward().interact(database).name("Commit")
                    .toward().destroy order
            @lp = diagram.find(".interaction:eq(2)").self().fragment name: "Loop", condition: "[until complete]"
            $.uml(".ref", "Complete Order and Pay").appendTo diagram
            menumanager.lost()
            $(".object", diagram).align "bottom"
            diagram.compose()

            @lp0 = lp.clone().insertAfter lp
            lp.extendWidth left:20, right: 10
        then_it "shifts to left by 20", ->
            @lp.offset().left.shouldBe @lp0.offset().left - 20
        then_it "shifts to right by 10", ->
            @lp.outerRight().shouldBe @lp0.outerRight() + 10

    description "alt", ->
        scenario "building alt having 4 objects fromt left to right", ->
            given "4 objects", ->
                @diagram = $.uml(".sequence-diagram")
                            .append(@obj_a = $.uml ".object", "a")
                            .append(@obj_b = $.uml ".object", "b")
                            .append(@obj_c = $.uml ".object", "c")
                            .append(@obj_d = $.uml ".object", "d")
                diagram.appendTo $("body")
            given "an interaction", ->
                @occur = obj_a.activate()
                occur.interact obj_b
            when_it "append alt .fragment", ->
                @iact = occur.interact stereotype: ".alt", {
                    "[x > 0]":(a) -> a.interact obj_b
                    "[x < 0]":(a) -> a.interact obj_c
                    "[else]" :(a) -> a.interact obj_d
                }
            when_it "refer alt. 2nd node under the occurrence is .alt", ->
                @alt = occur.find("> *:eq(1)")
            when_it "composing", ->
                diagram.compose()
            then_it ".alt.fragment is", ->
                diagram.find(".alt.fragment").expect length:1
            and_ "returning is .occurrence", ->  ## Because there are some .interacions in the fragment
                iact.attr("uml\:type").shouldBe ".occurrence"
            and_ "composition", ->
                alt.hasClass("alt").shouldBe true
            and_ "alt has", ->
                alt.find("> *:eq(0)")    .expect((e) -> e.hasClass "header")
                       .find("> *:eq(0)")    .expect((e) -> e.hasClass "name")   .end().end()
                   .find("> *:eq(1)")    .expect((e) -> e.hasClass "condition")  .end()
                   .find("> *:eq(2)")    .expect((e) -> e.hasClass "interaction").end()
                   .find("> *:eq(3)")    .expect((e) -> e.hasClass "divider")    .end()
                   .find("> *:eq(4)")    .expect((e) -> e.hasClass "condition")  .end()
                   .find("> *:eq(5)")    .expect((e) -> e.hasClass "interaction").end()
                   .find("> *:eq(6)")    .expect((e) -> e.hasClass "divider")    .end()
                   .find("> *:eq(7)")    .expect((e) -> e.hasClass "condition")  .end()
                   .find("> *:eq(8)")    .expect((e) -> e.hasClass "interaction").end()

        scenario "two interactions in .alt, last one is only in .alt fragment", ->
            given "2 objects", ->
                @diagram = $.uml(".sequence-diagram")
                            .append(@obj_a = $.uml ".object", "a")
                            .append(@obj_b = $.uml ".object", "b")
                diagram.appendTo $("body")
            when_it "append alt .fragment", ->
                obj_a.activate().interact stereotype: ".alt", {
                    "[x > 0]":(a) ->
                        (a.interact obj_b).name "A"
                        (a.interact obj_b).name "B"
                }
            when_it "composing", ->
                diagram.compose()
            then_it "the first interaction is out from the .alt fragment", ->
                diagram.find(".activated.interaction > .occurrence > *:eq(1) .name").text().shouldBe "A"
            and_ "the interaction 'B' is in the combined fragment", ->
                @alt = diagram.find(".activated.interaction > .occurrence > *:eq(0)")
                alt.find(".interaction .name").text().shouldBe "B"
            and_ "the alt has one interaction", ->
                alt.find(".interaction").length.shouldBe 1
