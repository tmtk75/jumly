before = ->
        @diag = $.jumly(".sequence-diagram")
                 .append(@obj_a = $.jumly(".object"))
                 .append(@obj_b = $.jumly(".object"))
                 .append(@obj_c = $.jumly(".object"))
        @diag.appendTo($("body"))
        @occurr_a = @obj_a.activate()
        @iact_a   = $.jumly(@occurr_a.parents(".interaction"))[0]
        @iact_ab  = @occurr_a.interact(@obj_b)
        @occurr_b = @iact_ab.gives(".occurrence").as(".actee")
        @iact_bc  = @occurr_b.interact(@obj_c)
        @occurr_c = @iact_bc.gives(".occurrence").as(".actee")
        @fragment_ab = $.jumly(".fragment").enclose(@iact_ab)
    
description 'object for sequence diagram', ->
    beforeEach -> before()
    # object
    it "should have an attr uml:property", ->
        obj_a.data("uml:property").type.shouldBe ".object"
    it "should have attr() as a jQuery object", ->
        (typeof obj_a.attr).shouldBe "function"
    it "should have .object", ->
        obj_a.hasClass('object').shouldBe true
    it "should have activate", ->
        (typeof obj_a.activate).shouldBe 'function'
    it "is an occurrence activate() returns", ->
        obj_a.activate().hasClass('occurrence').shouldBe true
    it "should be capable where is left at for given object", ->
        (typeof obj_a.isLeftAt).shouldBe "function"
    it "should be capable where is right at for given object", ->
        (typeof obj_a.isRightAt).shouldBe "function"
    it "should be hidden for .icon", ->
        $(".object .icon", diag).length.shouldBe 0
    it "should have .icon by iconify", ->
        obj_a.iconify().find(".icon").css("display").shouldBe "inline"
    it "should have .iconified by iconify", ->
        obj_a.iconify().hasClass("iconified").shouldBe true
    
    # interaction
    it "should have an attr uml:property", ->
        iact_a.data("uml:property").type.shouldBe ".interaction"
    it "should have nothing as owner", ->
        (iact_a.gives(".object") is null).shouldBe true
    it "shouldn't have a occurrence of actor object", ->
        (iact_a.gives(".occurrence").as(".actor") is null).shouldBe true
    it "should have a occurrence of actee object", ->
        expect(iact_a.gives(".occurrence").as(".actee")).toBe occurr_a
    it "should return false for iact_a", ->
        iact_a.is_to_itself().shouldBe false
    it "should return false for iact_ab", ->
        iact_ab.is_to_itself().shouldBe false

    it "should have an actor", ->
        (iact_a.gives(".occurrence").as(".actor") is null).shouldBe true
    it "should have an actee", ->
        expect(iact_a.gives(".occurrence").as(".actee").gives(".object")).toBe obj_a
    it "shouldn't be contained in an interaction created by activate() ", ->
        $(".message", iact_a).length.shouldBe 2
    it "should be capable to return <<return>>", ->
        expect(iact_a.reply()).toBe iact_a
    it "should fragment", ->
        iact_a.fragment().hasClass("fragment").shouldBe true
    
    # occurrence
    it "should have an attr uml:property", ->
        occurr_a.data("uml:property").type.shouldBe ".occurrence"
    it "should have an attr uml:property", ->
        occurr_b.data("uml:property").type.shouldBe ".occurrence"
    #NOTE: Can enable by improving 'interact'.
    #it "should have an interaction as actor", {'occurr_a.gives(".interaction").as("actor") === iact_a'.js_true()}
    it "should have an object as owner", ->
        expect(occurr_a.gives(".object")).toBe obj_a
    it "shouldn't be initially on a occurrence", ->
        occurr_a.isOnOccurrence().shouldBe false
    it "should return null for occurrence which itself is on", ->
        expect(occurr_a.parentOccurrence()).toBe null
    it "should return 0 for shift to parent", ->
        occurr_a.shiftToParent().shouldBe 0
    it "should return the nearest occurrence for given object", ->
        expect(occurr_c.preceding(obj_a)).toBe occurr_a
    # message
    it "should have an attr uml:property", ->
        diag.find(".message").data("uml:property").type.shouldBe ".message"
    it "should be held by an interaction", ->
        expect(diag.$(".message")[0].gives(".interaction")).toBe iact_ab
    it "should be capable to point the direction", ->
        (typeof diag.$(".message")[0].isToward).shouldBe "function"
    it "should be capable whether is toward right", ->
        (typeof diag.$(".message")[0].isTowardRight).shouldBe "function"
    it "should be capable whether is toward left",  ->
        (typeof diag.$(".message")[0].isTowardLeft).shouldBe "function"
    
    # fragment
    it "should have an attr uml:property", ->
        diag.$0(".fragment").data("uml:property").type.shouldBe ".fragment"
    it "should be created", ->
        diag.$(".fragment")[0].hasClass("fragment").shouldBe true
    it "should have class 'fragment'", ->
        fragment_ab.hasClass("fragment").shouldBe true
    it "should have enclose()", ->
        (typeof fragment_ab.enclose).shouldBe "function"
    
    # ref
    it "should have an attr uml:property", ->
        $.jumly(".ref").data("uml:property").type.shouldBe ".ref"
    it "should have class 'ref'", ->
        $.jumly(".ref").hasClass("ref").shouldBe true
    it "shodld have preferredWidth", ->
        (typeof $.jumly(".ref").preferredWidth).shouldBe "function"
    
    # diag.am
    it "should have an attr uml:property", ->
        diag.data("uml:property").type.shouldBe ".sequence-diagram"
    it "should be capable to find with selector", ->
        expect(diag.$(".interaction")[0].gives(".occurrence").as(".actee")).toBe occurr_a
    it "should return nothing for compose", ->
        diag.compose().hasClass("sequence-diagram").shouldBe true
    it "should return itself for compose()", ->
        expect(diag).toBe diag.compose()
    it "should have preferences", ->
        (typeof diag.preferences).shouldBe "function"
    it "should be preferences have WIDTH", ->
        (typeof diag.preferences().WIDTH).shouldBe "number"
    it "should be preferences have HEIGHT", ->
        (typeof diag.preferences().HEIGHT).shouldBe "number"
    it "should have preferredWidth", ->
        expect(typeof diag.preferredWidth).toBe "function"
    
    # diag.am.$0
    it 'should return the 1st object', ->
        expect(diag.$0(".object")).toBe obj_a
    it 'should return the 3rd object', ->
        expect(diag.$0(".object:eq(2)")).toBe obj_c
    
    # $.jumly
    it "should return the same instance for diag", ->
        expect($.jumly($("body > .diagram:last")[0])[0][0] is diag[0]).toBe true
    it "should have .diagram", ->
        $.jumly($("body > .diagram"))[0].hasClass("diagram").shouldBe true
    it 'should be improved at accessibility to instances using $.jumly', ->
        
    it "should return the same object for selector", ->
        expect($.jumly($(".occurrence", iact_a))[0]).toBe occurr_a
    it 'should store jQuery instance in self()', ->
        expect(occurr_b.self()).toBe occurr_b
    
