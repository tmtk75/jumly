description "lifeline", ->
    shared_behavior "lifeline for 1 object", ->
        given "a diagram and 1 object", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: 33
                height: 32
            ))
            diagram.appendTo $("body")
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "guarantee 'lifeline for 1 object' for lifeline", ->
        it_behaves_as "lifeline for 1 object"
        then_it "lifeline.length=1", ->
            $(".lifeline", diagram).length.shouldBe 1
        
        and_ "the width is equal to the object", ->
            obj_a.width().shouldBe diagram.$(".lifeline")[0].width()
        
        and_ "the height is further greater than 0", ->
            diagram.$(".lifeline")[0].height().shouldBeGreaterThan 0
        
        and_ "lifeline is at bottom of object", ->
            diagram.$(".lifeline")[0].offset().top.shouldBe diagram.$(".object")[0].outerBottom() + 1
    
    shared_behavior "lifelines for 3 objects", ->
        given "a diagram and 3 objects", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object").offset(left: 50).css(
                width: 33
                height: 33
            )).append(obj_b = $.uml(".object").offset(left: 100).css(
                width: 50
                height: 34
            )).append(obj_c = $.uml(".object").offset(left: 150).css(
                width: 88
                height: 35
            ))
            diagram.appendTo $("body")
        
        when_it "composing", ->
            diagram.compose()
    
    scenario "guarantee 'lifelines for 3 objects' for lifeline", ->
        it_behaves_as "lifelines for 3 objects"
        then_it "lifeline.length=3", ->
            $(".lifeline", diagram).length.shouldBe 3
        
        and_ "3rd lifeline is at bottom of the object", ->
            diagram.$(".lifeline")[2].offset().top.shouldBe diagram.$(".object")[2].outerBottom() + 1
    
    scenario "number of lifeline is equal to number of object no matter how compose twice", ->
        it_behaves_as "lifelines for 3 objects"
        when_it "2nd composig", ->
            diagram.compose()
        
        then_it "lifeline.length=3", ->
            $(".lifeline", diagram).length.shouldBe 3
    
    shared_behavior "given a lifeline", ->
        given "a lifeline outside diagram", ->
            @obj = $.uml(".object")
            @ll = obj.activate()
    
    scenario "should be 0 just after the creation outside diagram", ->
        it_behaves_as "given a lifeline"
        then_it "should be 0", ->
            ll.width().shouldBe 0
    
    shared_behavior "given a diagram", ->
        it_behaves_as "given a lifeline"
        given "a diagram outside document", ->
            @diag = $.uml(".sequence-diagram")
    
    scenario "should be 0 if nodes are not in HTML document", ->
        it_behaves_as "given a diagram"
        when_it "adding the lifeline to the diagram", ->
            diag.append ll
        
        then_it "should be 0", ->
            ll.width().shouldBe 0
    
    scenario "should be greater than 0 if nodes are in HTML document", ->
        it_behaves_as "given a diagram"
        when_it "adding the lifeline to the diagram", ->
            diag.append ll
        
        when_it "adding the diagram into the HTML document", ->
            $("body").append diag
        
        then_it "should be 0", ->
            ll.width().shouldBeGreaterThan 0

    shared_behavior "two creations and two usual interactions", ->
        given "three .object", ->
            @diag = $.uml ".sequence-diagram"
            @diag.append(@obj_a = $.uml ".object", "a")
            @diag.append(@obj_d = $.uml ".object", "d")
            @diag.append(@obj_e = $.uml ".object", "e")
        when_it "create five messages", ->
            @iact_ab = @obj_a.activate()
                             .create(id:"obj_b", name:"b")
                             .awayfrom().create(id:"obj_c", name:"c")
                             .awayfrom().interact(@obj_d).name("a -> d")
                             .awayfrom().interact(@obj_e).name("a -> e")
            @obj_b = @diag.obj_b
            @obj_c = @diag.obj_c
            @obj_a.offset left:400
            @obj_b.offset left:50
            @obj_c.offset left:600
            @obj_d.offset left:200
            @obj_e.offset left:500
        when_it "compose", ->
            @diag.appendTo $ "body"
            @diag.compose()

    description "lifecycle", ->
        scenario ".lifeline is created when composing", ->
            given "an .object", ->
                @diag = $.uml(".sequence-diagram").append(@obj_a = $.uml ".object")
                diag.appendTo $ "body"
            when_it "compose", ->
                diag.compose()
            then_it "the .lifeline for the .object", ->
                $(".lifeline", @diag).length.shouldBe 1

        scenario "meta association", ->
            it_behaves_as "two creations and two usual interactions"
            #then_it "from obj_a", ->
            #    @obj_a.gives(".lifeline").hasClass("lifeline").shouldBe true
            then_it "from lifeline", ->
                @diag.find(".lifeline:eq(0)").data("uml:this").gives(".object").hasClass("object").shouldBe true
                @diag.hide()
    
        scenario "top of lifeline", ->
            it_behaves_as "two creations and two usual interactions"
            then_it "", ->
                c = ["red", "blue", "yellow", "gray", "green"]
                @diag.find(".lifeline").each (i, e) ->
                    e = $(e).data("uml:this")
                    obj = e.gives(".object")
                    obj.outerBottom().shouldBe e.offset().top - 1
#                    e.css "border", "solid 1px #{c[i]}"

    scenario "lifeline length is aligned", ->
        given "a sequence", ->
            @diag = $.uml(".sequence-diagram")
            diag.appendTo $ "body"
            diag.found "A", ->
                @message "b", "B", ->
                    @message "c", "C", ->
                        @message "d", "D", ->
            diag.compose()
        then_it "length is same", ->
            a = diag.find(".lifeline:eq(0)").data("uml:this")
            b = diag.find(".lifeline:eq(1)").data("uml:this")
            c = diag.find(".lifeline:eq(2)").data("uml:this")
            d = diag.find(".lifeline:eq(3)").data("uml:this")

            a.outerBottom().shouldBe b.outerBottom()
            b.outerBottom().shouldBe c.outerBottom()
            c.outerBottom().shouldBe d.outerBottom()

    scenario "lifeline length for .stop", ->
        given "a", ->
            @diag = $.uml(".sequence-diagram")
            diag.appendTo $ "body"
            diag.found "A", ->
                @message "b", "B", ->
                    @message "d", "D", ->
                    @message "c", "C", ->
                        @message destroy:"d", "D", ->
            diag.compose()
        then_it "", ->

