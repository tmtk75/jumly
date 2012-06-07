u = $.jumly
description "sequence-diagram.fragment.loop", ->
  it "should look good", ->
    diag = u ".sequence-diagram"
    ctxt = diag.found "You-loop-1", ->
      @create "", "Order-loop-2", ->
        @loop @message "mail", "Me-loop-3", ->
          @message "read", ->
          @reply "", diag["You-loop-1"]
    ctxt.compose $ "body"
    widthBetween23 = diag.find(".object").not(":eq(0)").mostLeftRight().width()
    diag.find(".loop").outerWidth().shouldBeLessThan widthBetween23

  it "should enclose multi-interactions", ->
    diag = u ".sequence-diagram"
    ctxt = diag.found "You-loop-5", ->
      @message "mail", "Me-loop-6"
      @message "read", "Me-loop-7"
    frag = u ".fragment"
    frag.enclose diag.find(".occurrence > .interaction")
    frag.name "Loop"
    ctxt.compose $ "body"
    expect(diag.find(".fragment > .interaction").length).toBe 2
