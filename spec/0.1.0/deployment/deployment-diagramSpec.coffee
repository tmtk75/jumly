xdescription "deployment-diagram", ->
    description "location", ->
        shared_behavior "is located to the dialog", ->
            given "an artifact", ->
                @diag = $.jumly ".deployment-diagram"
                @art  = $.jumly ".artifact", "foobar"
                diag.append art
                diag.appendTo $ "body"
            then_it "composing", ->
                diag.compose()
        
        scenario "located to (0, 0)", ->
            it_behaves_as "is located to the dialog"
            when_it "moveTo(0, 0)", ->
                art.moveTo(0, 0)
            then_it "is at (0, 0) of the diagram", ->
                @art.offset().left.shouldBe @diag.offset().left
            and_ ->
                @art.offset().top.shouldBe @diag.offset().top

        scenario "located to (200, 100)", ->
            it_behaves_as "is located to the dialog"
            when_it "moveTo(200, 100)", ->
                art.moveTo 200, 100
            then_it "is at (200, 100) of the diagram", ->
                @art.offset().left.shouldBe @diag.offset().left + 200
            and_ ->
                @art.offset().top.shouldBe @diag.offset().top + 100
        
        scenario "3 artifacts vertical", ->
            given "an artifact", ->
                @diag = $.jumly ".deployment-diagram"
                diag.append @a = $.jumly ".artifact", "foobar"
                diag.append @b = $.jumly ".artifact", "fizbuz"
                diag.append @c = $.jumly ".artifact", "rock'in roll"
                diag.appendTo $ "body"
            when_it "move all to", ->
                a.moveTo top:300
                b.moveTo top:300 - a.outerHeight()
                c.moveTo top:300 + a.outerHeight()
            and_ ->
                diag.compose()
            then_it "offset...", ->
                @a.offset().top.shouldBe @diag.offset().top
            and_ ->
                @b.offset().top.shouldBe @diag.offset().top
            and_ ->
                @c.offset().top.shouldBe @diag.offset().top

    description "size", ->
        scenario "preferredWidth", ->
            it_behaves_as "is located to the dialog"
            when_it "set preferredWidth", ->
                @art.preferredWidth 100
            then_it "is 100", ->
                @art.width().shouldBe 100
    
        scenario "preferredWidth with moveTo", ->
            it_behaves_as "is located to the dialog"
            when_it "moveTo left:200, top:50", ->
                @art.moveTo 200, 50
            when_it "set preferredWidth", ->
                @art.preferredWidth 150
            then_it "is 150", ->
                @art.width().shouldBe 150
        
        scenario "preferredWidth with moveTo right", ->
            it_behaves_as "is located to the dialog"
            when_it "moveTo left:200, top:50", ->
                @art.moveTo 1000, 50
            when_it "set preferredWidth", ->
                @art.preferredWidth 250
            then_it "is 250", ->
                @art.width().shouldBe 250

