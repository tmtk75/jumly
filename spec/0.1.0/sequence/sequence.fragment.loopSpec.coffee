u = $.jumly
description "sequence-diagram.fragment.loop", ->

    it "should look good", ->
        diag = u ".sequence-diagram"
        ctxt = diag.found "You", ->
            @create "", "Order", ->
                @loop @message "mail", "Me", ->
                    @message "read", ->
                    @reply "", "You"
        ctxt.compose $ "body"

        widthBetween23 = diag.find(".object").not(":eq(0)").mostLeftRight().width()
        diag.find(".loop").outerWidth().shouldBeLessThan widthBetween23

    it "should enclose multi-interactions", ->
        diag = u ".sequence-diagram"
        ctxt = diag.found "You", ->
            @message "mail", "Me"
            @message "read", "Me"
        
        frag = u ".fragment"
        frag.enclose diag.find(".occurrence > .interaction")
        frag.name "Loop"
        
        ctxt.compose $ "body"

        expect(diag.find(".fragment > .interaction").length).toBe 2
