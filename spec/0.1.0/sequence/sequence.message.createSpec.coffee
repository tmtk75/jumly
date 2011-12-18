description "message.create", ->
    shared_scenario "a creation", ->
        given "an .object", ->
            @diag = $.uml ".sequence-diagram"
            @diag.append(@obj_a = $.uml ".object", "a")
        when_it "create message", ->
            @iact_ab = @obj_a.activate().create id:"obj_b", name:"b"
        then_it "two object there", ->
            @diag.find(".object").length.shouldBe 2
        and_ "the height of the new one is down", ->
            @diag.obj_b.offset().top.shouldBeGreaterThan @obj_a.outerBottom()
    
    shared_scenario "more creation", ->
        it_behaves_as "a creation"
        when_it "create message more from obj_b", ->
            @iact_bc = @iact_ab.toward().create id:"obj_c", name:"c"
        then_it "three object there", ->
            @diag.find(".object").length.shouldBe 3
        and_ "the height of the new one is down more", ->
            @diag.obj_c.offset().top.shouldBeGreaterThan @diag.obj_b.outerBottom()
    
    shared_scenario "shift occurrence downward", ->
        it_behaves_as "a creation"
        when_it "create message", ->
            @iact_ab2 = @iact_ab.awayfrom().interact @diag.obj_b
        when_it "", ->
            @above = @iact_ab.gives(".occurrence").as ".actee"
            @below = @iact_ab2.gives(".occurrence").as ".actee"
            @above.css "background-color":"#fbb"
            @below.css "background-color":"#bbf"
        then_it "the occurrence is below from former", ->
            @below.offset().top.shouldBeGreaterThan @above.outerBottom()
    
    shared_scenario "overlap example", ->
        it_behaves_as "more creation"
        when_it "create 4th one", ->
            @iact_bd = @iact_ab.toward().create id:"obj_d", name:"d"
        when_it "swap the position holizontally", ->
            @diag.appendTo $ "body"
            @diag.compose()
            bx = @diag.obj_b.offset().left
            cx = @diag.obj_c.offset().left
            dx = @diag.obj_d.offset().left
            @diag.obj_b.offset left:cx
            @diag.obj_c.offset left:dx
            @diag.obj_d.offset left:bx
        when_it "shift upward with negative margin-top", ->
            @iact_bd.css "margin-top": -40
            @diag.compose()
        then_it "the occurrence is below from former", ->
            top    = diag.obj_c.offset().top
            bottom = diag.obj_c.outerBottom()
            y      = diag.obj_d.offset().top
            top.shouldBeLessThan y
            y.shouldBeLessThan bottom
            @diag.hide()

    scenario "create message to right", ->
        it_behaves_as "a creation"
        when_it "compose", ->
            diag.prependTo $("body")
            diag.compose()
        then_it "to left edge", ->
            msg = @iact_ab.find(".message").self()
            can = msg._current_canvas
            e = msg._to_create_line can
            canx = $(can).offset().left
            @diag.obj_b.offset().left.shouldBe canx + e.dst.x
            @diag.hide()

    scenario "create message to left", ->
        it_behaves_as "a creation"
        given "a new .object", ->
            @iact_ab.awayfrom().create id:"obj_c", name:"c"
        given "some messages", ->
            @iact_ab.interact @diag.obj_b
            @iact_ab.interact @diag.obj_c
        when_it "swap", ->
            @diag.appendTo $ "body"
            @diag.compose()
            ax = @obj_a.offset().left
            bx = @diag.obj_b.offset().left
            @obj_a.offset left:bx
            @diag.obj_b.offset left:ax
            @diag.compose()
        then_it "", ->
            msg = @iact_ab.find(".message").self()
            e = msg._to_create_line msg._current_canvas
            can = $(msg._current_canvas)
            canr = can.offset().left + can.width()
            b = @diag.obj_b
            (b.offset().left + b.outerWidth()).shouldBe can.offset().left + e.dst.x

    scenario "centering name", ->
        given "an .object", ->
            @diag = $.uml ".sequence-diagram"
            @diag.append(@obj_a = $.uml ".object", "a")
            @diag.append(@obj_d = $.uml ".object", "d")
            @diag.append(@obj_e = $.uml ".object", "e")
        when_it "create message", ->
            @iact_ab = @obj_a.activate()
                             .create(id:"obj_b", name:"b")
                             .awayfrom().create(id:"obj_c", name:"c")
                             .awayfrom().interact(@obj_d).name("Harry")
                             .awayfrom().interact(@obj_e).name("Potter")
            @obj_b = @diag.obj_b
            @obj_c = @diag.obj_c
            @obj_a.offset left:400
            @obj_b.offset left:50
            @obj_c.offset left:600
            @obj_d.offset left:200
            @obj_e.offset left:500
        when_it "", ->
            @diag.appendTo $ "body"
            @diag.compose()
        then_it "", ->

