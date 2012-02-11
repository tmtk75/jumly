description "lifeline", ->
    shared_behavior "lifeline for 1 object", ->
        given "a diagram and 1 object", ->
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").offset(left: 50).css(
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
            @diagram = $.jumly(".sequence-diagram").append(@obj_a = $.jumly(".object").offset(left: 50).css(
                width: 33
                height: 33
            )).append(obj_b = $.jumly(".object").offset(left: 100).css(
                width: 50
                height: 34
            )).append(obj_c = $.jumly(".object").offset(left: 150).css(
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
            @obj = $.jumly(".object")
            @ll = obj.activate()
    
    scenario "should be 0 just after the creation outside diagram", ->
        it_behaves_as "given a lifeline"
        then_it "should be 0", ->
            ll.width().shouldBe 0
    
    shared_behavior "given a diagram", ->
        it_behaves_as "given a lifeline"
        given "a diagram outside document", ->
            @diag = $.jumly(".sequence-diagram")
    
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
            @diag = $.jumly ".sequence-diagram"
            @diag.append(@obj_a = $.jumly ".object", "a")
            @diag.append(@obj_d = $.jumly ".object", "d")
            @diag.append(@obj_e = $.jumly ".object", "e")
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
                @diag = $.jumly(".sequence-diagram").append(@obj_a = $.jumly ".object")
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
                @diag.find(".lifeline:eq(0)").self().gives(".object").hasClass("object").shouldBe true
                @diag.hide()
    
        scenario "top of lifeline", ->
            it_behaves_as "two creations and two usual interactions"
            then_it "", ->
                c = ["red", "blue", "yellow", "gray", "green"]
                @diag.find(".lifeline").each (i, e) ->
                    e = $(e).self()
                    obj = e.gives(".object")
                    obj.outerBottom().shouldBe e.offset().top - 1
#                    e.css "border", "solid 1px #{c[i]}"

    scenario "lifeline length is aligned", ->
      given "a sequence", ->
        @diag = $.jumly(".sequence-diagram")
        diag.appendTo $ "body"
        diag.found "A-ll-0", ->
          @message "b", "B-ll-1", ->
            @message "c", "C-ll-2", ->
              @message "d", "D-ll-3", ->
        diag.compose()
      then_it "length is same", ->
        a = diag.find(".lifeline:eq(0)").self()
        b = diag.find(".lifeline:eq(1)").self()
        c = diag.find(".lifeline:eq(2)").self()
        d = diag.find(".lifeline:eq(3)").self()
        a.outerBottom().shouldBe b.outerBottom()
        b.outerBottom().shouldBe c.outerBottom()
        c.outerBottom().shouldBe d.outerBottom()

    scenario "lifeline length for .stop", ->
      given "a", ->
        @diag = $.jumly(".sequence-diagram")
        diag.appendTo $ "body"
        diag.found "A-ll-4", ->
          @message "b", "B-ll-5", ->
            @message "d", "D-ll-6", ->
            @message "c", "C-ll-7", ->
              @message destroy:"d", "D-ll-8", ->
        diag.compose()
      then_it "", ->
