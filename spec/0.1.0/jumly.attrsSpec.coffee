description "attr", ->
    it "has stereotype property to read/write", ->
        diag = $.jumly ".sequence-diagram"
        diag.found "A", ->
            @create "B"
        msg = (diag.find ".message:last").self()
        (msg.hasClass "create").shouldBeTruthy()
        #msg.jprops().stereotypes().length.shouldBe 1
    
    it "has name property to read/write", ->
        diag = $.jumly ".sequence-diagram"
        diag.found "A", ->
            @message "call", "B"
        msg = (diag.find ".message:last").self()
        #msg.jprops().name.shouldBe "call"

    scenario "a string at 2nd parameter in creation", ->
        given "a string at 2nd parameter", ->
            @obj_a = $.jumly(".object", "hello world")
        then_it "the value is in nodes has .name", ->
            obj_a.find(".name:eq(0)").html().shouldBe "hello world"
    
    scenario "an object at 2nd parameter in creation", ->
        given "an object having 'name' at 2nd parameter", ->
            @obj_a = $.jumly(".object", name: "hello world2")
        then_it "the value of the name property for the object is in nodes has .name", ->
            obj_a.find(".name:eq(0)").html().shouldBe "hello world2"
    
    scenario "name method", ->
        given "an object", ->
            @obj_a = $.jumly(".object")
        and_ "an interaction", ->
            @iact_aa = obj_a.activate().interact(obj_a)
        when_it "set a value with name to obj_a", ->
            @p = obj_a.name("foobar")
        and_ "set a value with name to iact_aa", ->
            @q = iact_aa.name("fizbuz")
        then_it "a value is in the object's .name", ->
            obj_a.find(".name:eq(0)").html().shouldBe "foobar"
        and_ "a value is in the interaction's .name", ->
            iact_aa.find(".name:eq(0)").html().shouldBe "fizbuz"
        then_it "p is obj_a", ->
            (p == obj_a).shouldBe true
        and_ "q is iact_aa", ->
            (q == iact_aa).shouldBe true
    
    scenario "basic attributes", ->
        given "a fragment", ->
            @diagram = $.jumly(".sequence-diagram")
                        .append(@obj_a = $.jumly(".object").offset(left:  50).css(width: 88, height: 31))
                        .append(@obj_b = $.jumly(".object").offset(left: 150).css(width: 88, height: 31))
            diagram.appendTo $("body")
            obj_a.activate().interact obj_b
            @frag = $.jumly(".fragment")
                     .enclose($("> .interaction:eq(0)", diagram))
                     .name("Loop-0")
                     .find(".condition").html("[person is empty]")
        then_it "name of the fragment is 'Loop-0'", ->
            frag.find(".name").html().shouldBe "Loop-0"
        and_ "condition of the fragment is the value", ->
            frag.find("> .header .condition").html().shouldBe "[person is empty]"
    
    shared_behavior "all elements", ->
        given "all elements", ->
            @diagram = $.jumly(".sequence-diagram")
                        .append(@obj_a = $.jumly(".object").offset(left:  50).css(width: 88, height: 31))
                        .append(@obj_b = $.jumly(".object").offset(left: 150).css(width: 88, height: 31))
            diagram.appendTo $("body")
            obj_a.activate().interact(obj_b)
                            .interact(obj_b)
                            .interact(obj_b)
            @frag = $.jumly(".fragment").enclose($("> .interaction:eq(0)", diagram))
            diagram.compose()
  
    scenario "message stereotype", ->
        it_behaves_as "all elements"
        then_it "it has .asynchronous class", ->
        and_ "it has .synchronous class", ->
        and_ "it has .create class", ->
        and_ "it has .destroy class", ->

    xscenario "diagram listener", ->
        it 'can recognize diagram composed to use lazy-invocation after resizing', ->
            "NOT IMPLEMENTED".shouldBe ""

