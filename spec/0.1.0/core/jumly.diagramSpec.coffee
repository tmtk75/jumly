description "diagram", ->
    shared_behavior "a sequence diagram", ->
        given "a sequence diagram", ->
            @diag = $.jumly(".sequence-diagram")
            $("body").append(diag)

    scenario "width of an empty sequence diagram", ->
        it_behaves_as "a sequence diagram"
        when_it "composed", ->
            diag.compose()
        then_it "should be 0", ->
            expect(0).toEqual diag.preferredWidth()
    
    shared_behavior "a composed sequence diagram", ->
        it_behaves_as "a sequence diagram"
        given "an object",  ->
            diag.append @obj_a = $.jumly(".object")
        when_it "is composed", ->
            diag.compose()
    
    scenario "width of sequence diagram", ->
        it_behaves_as "a composed sequence diagram"
        then_it "should be greater than obj_a's width", ->
            expect(obj_a.width() <= diag.preferredWidth()).toBeTruthy()

    description "width of sequence diagram", ->
        shared_behavior "two objects in sequence diagram", ->
            given "two objects in a diagram", ->
                @diag  = $.jumly(".sequence-diagram")
                          .append(@obj_a = $.jumly ".object", "a")
                          .append(@obj_b = $.jumly ".object", "b")
                @diag.appendTo $ "body"
    
        scenario "two objects in sequence diagram:0", ->
            it_behaves_as "two objects in sequence diagram"
            when_it "0:0, 0:0", ->
                obj_a.width(0).offset left:0
                obj_b.width(0).offset left:0
            then_it "0", ->
                expect(diag.preferredWidth()).toEqual 0
        ###
        NOTE: Usually, body element has initially margin about 8px.
              If you set the left of an object to zero with .offset(),
              css's left property goes to -8px. So some below scenarios are failed.
        ###
        scenario "two objects in sequence diagram:1", ->
            it_behaves_as "two objects in sequence diagram"
            when_it "0:0, 0:1", ->
                obj_a.width(0).offset left:0
                obj_b.width(0).offset left:1
            then_it "1", ->
                ## This is an so edge case ;)
                expect(diag.preferredWidth()).toEqual 0
        
        scenario "two objects in sequence diagram:2", ->
            it_behaves_as "two objects in sequence diagram"
            when_it "1:0, 1:1", ->
                obj_a.width(1).offset left:0
                obj_b.width(1).offset left:1
            then_it "2", ->
                expect(diag.preferredWidth()).toEqual 2
        
        scenario "two objects in sequence diagram:a", ->
            it_behaves_as "two objects in sequence diagram"
            when_it "88:0, 88:138", ->
                obj_a.width(88).offset left:0
                obj_b.width(88).offset left:(88 + 50)
            then_it "should be the distance b/w two", ->
                expect(diag.preferredWidth()).toEqual (88 + 50) + 88 
        
        shared_behavior "four objects", ->
            it_behaves_as "two objects in sequence diagram", ->
            given "two objects in a diagram", ->
                diag.append(@obj_c = $.jumly ".object", "c")
                    .append(@obj_d = $.jumly ".object", "d")
    
        scenario "four objects", ->
            it_behaves_as "four objects", ->
            when_it "", ->
                $.jumly.preferences(".sequence-diagram", $.jumly.preferences(".sequence-diagram:system-default"))
            when_it "composed", ->
                diag.appendTo $ "body"
                diag.compose()
            and_ "some parameters", ->
                @span = obj_b.offset().left - obj_a.outerRight()
                @objw = obj_a.width()
            then_it "preferredWidth", ->
                l = @obj_a.offset().left
                diag.preferredWidth().shouldBeGreaterThan 526
            and_ "left", ->
                (obj_a.position().left >=  0).shouldBeTruthy()

        scenario "private prefs", ->
            it_behaves_as "four objects", ->
            when_it "", ->
                diag.preferences($.jumly.preferences(".sequence-diagram:system-default"))
            when_it "composed", ->
                diag.appendTo $ "body"
                diag.compose()
            then_it "preferredWidth", ->
                l = @obj_a.offset().left
                diag.preferredWidth().shouldBeGreaterThan 526
            and_ "left", ->
                (obj_a.position().left >=  0).shouldBeTruthy()

