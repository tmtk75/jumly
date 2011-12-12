description "jumly", ->
    shared_behavior "create an object and refers with 2ways", ->
        given "an object out from uml()", ->
            @diagram = $.uml(".sequence-diagram")
            @obj_a = $.uml(".object")
            @obj_b = $.uml(".object")
        
        when_it "append it into body", ->
            diagram.append obj_a
        
        and_ "get it again with jQuery selector", ->
            @a0 = $.uml($(".object:last", diagram)[0])
        
        and_ "get also it as jQueery object", ->
            @a1 = $.uml($(".object:last", diagram))
    
    scenario "identification for single object (guarantee 'create an object and refers with 2ways')", ->
        it_behaves_as "create an object and refers with 2ways"
        then_it "a0 has length which is number", ->
            (typeof a0.length == "number").shouldBe true
        
        and_ "a1 has length which is number, too", ->
            (typeof a1.length == "number").shouldBe true
        
        and_ "it equals to the given one", ->
            (obj_a == a0[0]).shouldBe true
        
        and_ "it also equals to another one", ->
            (obj_a == a1[0]).shouldBe true
        
        and_ "the length is 1", ->
            (1 == a0.length).shouldBe true
        
        and_ "also 1, too", ->
            (1 == a1.length).shouldBe true
        
        and_ "a0 has each method", ->
            (typeof a0.each == "function").shouldBe true
        
        and_ "a1 has each method", ->
            (typeof a1.each == "function").shouldBe true
    
    shared_behavior "create 2nd object in the diagram", ->
        it_behaves_as "create an object and refers with 2ways"
        when_it "creating 2nd object", ->
            diagram.append obj_b.hide()
        
        and_ "selecting multiple objects", ->
            @objs = $.uml($(".object", diagram))
    
    scenario "identification for multiple objects (guarantee 'create 2nd object in the diagram')", ->
        it_behaves_as "create 2nd object in the diagram"
        then_it "the length is 2", ->
            objs.length.shouldBe 2
        
        and_ "1st is obj_a", ->
            (obj_a == objs[0]).shouldBe true
        
        and_ "2nd is obj_b", ->
            (obj_b == objs[1]).shouldBe true
    
    scenario "with selector of jQuery", ->
        it_behaves_as "create 2nd object in the diagram"
        when_it "selecting an object", ->
            @a0 = diagram.$(".object:eq(0)")
        
        and_ "selecting another object", ->
            @a1 = diagram.$(".object:eq(1)")
        
        and_ "selecting the last object", ->
            @last = diagram.$(".object:last")
        
        then_it "the 1st one's len is 1", ->
            (a0.length == 1).shouldBe true
        
        and_ "the 2nd one's len is 1", ->
            (a1.length == 1).shouldBe true
        
        and_ "the last's len is 1", ->
            (last.length == 1).shouldBe true
        
        and_ "the 1st one equals obj_a", ->
            (a0[0] == obj_a).shouldBe true
        
        and_ "the 2nd one equals obj_b", ->
            (a1[0] == obj_b).shouldBe true
        
        and_ "the last equals obj_b", ->
            (last[0] == obj_b).shouldBe true
    
    shared_behavior "activating an occurrence", ->
        given "an .object and occurrence", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object"))
            @occurr_a = obj_a.activate()
            $("body").append diagram
    
    scenario ".object referred from .occurrence (ensure 'activating an occurrence')", ->
        it_behaves_as "activating an occurrence"
        then_it "the .object can be referred with a method", ->
            (occurr_a.gives(".object") == obj_a).shouldBe true
        
        then_it "not null", ->
            (occurr_a.gives(".object") != null).shouldBe true
    
    scenario "returning null nodes if not found", ->
        it_behaves_as "activating an occurrence"
        then_it "returns null", ->
            (occurr_a.gives(".foobar") is null).shouldBe true
    
    scenario "interactions for the 1st occurrence", ->
        it_behaves_as "activating an occurrence"
        given "the 1st interaction", ->
            @iact_a = $.uml($(".interaction:eq(0)", diagram))[0]
        
        then_it "no .interaction is as .actor", ->
            (iact_a.gives(".occurrence").as(".actor") == null).shouldBe true
        
        then_it ".interaction is as .actee", ->
            (iact_a.gives(".occurrence").as(".actee") == occurr_a).shouldBe true
    
    shared_behavior "an interacting", ->
        it_behaves_as "activating an occurrence"
        given "an new .object", ->
            @obj_b = $.uml(".object")
        
        and_ "an .interaction", ->
            @iact_ab = occurr_a.interact(obj_b)
        
        and_ "an new .occurrence which is created by interact", ->
            @occurr_b = $.uml(iact_ab.find(".occurrence"))[0]
        
        and_ "an new .message which is created by interact", ->
            @msg_ab = $.uml(iact_ab.find(".message"))[0]
    
    scenario "an .interaction with the .object and .occurrence (ensure 'an interacting')", ->
        it_behaves_as "an interacting"
        then_it "the .interaction gives the 1st .object", ->
            (iact_ab.gives(".object").as(".actor") == obj_a).shouldBe true
        
        and_ "the .interaction gives the 2nd .object", ->
            (iact_ab.gives(".object").as(".actee") == obj_b).shouldBe true
        
        and_ "the .interaction gives the .occurrence as .actor", ->
            (iact_ab.gives(".occurrence").as(".actor") == occurr_a).shouldBe true
        
        and_ "the .interaction gives a new .occurrence as .actee", ->
            (iact_ab.gives(".occurrence").as(".actee") == occurr_b).shouldBe true
        
        and_ "the .interaction gives the .message", ->
            (iact_ab.gives(".message") == msg_ab).shouldBe true
        
        then_it "the .message gives the .interaction", ->
            (msg_ab.gives(".interaction") == iact_ab).shouldBe true
        
        and_ "the .message gives the .occurrence of .actee through the interaction", ->
            (msg_ab.gives(".interaction").gives(".occurrence").as(".actee") == occurr_b).shouldBe true
        
        then_it "the new .occurrence gives the new 2nd .object", ->
            (occurr_b.gives(".object") == obj_b).shouldBe true
    
    scenario "lifeline giving/taking", ->
        it_behaves_as "activating an occurrence"
        when_it "composing", ->
            diagram.compose()
        
        and_ "taking a new lifeline", ->
            @ll_a = $.uml(diagram.find(".lifeline:eq(0)"))[0]
        
        then_it "the object gives/of the lifeline of itself", ->
            (diagram.gives(".lifeline").of(obj_a) == ll_a).shouldBe true
        
        then_it "not null", ->
            (ll_a != null).shouldBe true
        
        then_it "the object gives/of empty array for unrelated object", ->
            (diagram.gives(".lifeline").of($("")).length == 0).shouldBe true
    
    shared_behavior "create 2 divs into a diagram", ->
        given "a diagrma and 2 plain divs", ->
            @diagram = $.uml(".sequence-diagram").append("<div>").append("<div>")
    
    scenario "normal DOM node selection (guarantee 'create 2 divs into a diagram')", ->
        it_behaves_as "create 2 divs into a diagram"
        when_it "selecting all divs", ->
            @objs = $.uml($("div", diagram))
        
        then_it "length is 2", ->
            objs.length.shouldBe 2
        
        but_ "1st slot is null", ->
            (objs[0] == null).shouldBe true
        
        and_ "2nd slot is null", ->
            (objs[1] == null).shouldBe true
    
    shared_behavior "3 objects and simple interactions", ->
        given "a diagram", ->
            @diagram = $.uml(".sequence-diagram").append(@obj_a = $.uml(".object")).append(@obj_b = $.uml(".object")).append(@obj_c = $.uml(".object"))
            @ll_a = obj_a.activate()
            @ll_b = ll_a.interact(obj_b).gives(".occurrence").as(".actee")
            @ll_c = ll_b.interact(obj_c).gives(".occurrence").as(".actee")
    
    scenario "preceding of occurrence", ->
        it_behaves_as "3 objects and simple interactions"
        then_it "c for b is b", ->
            (ll_c.preceding(obj_b) == ll_b).shouldBe true
        
        and_ "c for a is a", ->
            (ll_b.preceding(obj_a) == ll_a).shouldBe true
        
        and_ "a for a is null", ->
            (ll_a.preceding(obj_a) == null).shouldBe true
        
        and_ "b for b is null", ->
            (ll_b.preceding(obj_b) == null).shouldBe true
        
        and_ "c for c is null", ->
            (ll_c.preceding(obj_c) == null).shouldBe true
        
        and_ "b for c is null", ->
            (ll_b.preceding(obj_c) == null).shouldBe true
    
    narrative "fundamental capability"
    shared_behavior "create an object", ->
        given "an object", ->
            @obj_a = $.uml(".object")
                      .name("foo")
                      .stereotype("bar")
    
    scenario "guarantee 'create an object' for getter", ->
        it_behaves_as "create an object"
        then_it "the name is 'foo'", ->
            @n = obj_a.name()
            n.shouldBe "foo"
        
        and_ "the stereotype is 'bar'", ->
            obj_a.stereotype().shouldBe "bar"
        
        and_ "uml:property returns an object having all attributes", ->
            @all = obj_a.data("uml:property")
        
        and_ "name", ->
            all.name.shouldBe "foo"
        
        and_ "stereotype", ->
            all.stereotype.shouldBe "bar"
    
    scenario "guarantee 'create an object' for setter", ->
        it_behaves_as "create an object"
        when_it "set name", ->
            obj_a.name "fiz"
        
        and_ "set stereotype", ->
            obj_a.stereotype "buz"
        
        then_it "the name is 'fiz'", ->
            obj_a.name().shouldBe "fiz"
        
        and_ "the stereotype is 'buz'", ->
            obj_a.stereotype().shouldBe "buz"
        
        and_ "uml:property returns an object having all attributes", ->
            @all = obj_a.data("uml:property")
        
        and_ "name", ->
            all.name.shouldBe "fiz"
        
        and_ "stereotype", ->
            all.stereotype.shouldBe "buz"
    
    scenario "empty string for name, stereotype", ->
        it_behaves_as "create an object"
        when_it "sets empty string", ->
            obj_a.name ""
            obj_a.stereotype ""
        
        then_it "returns empty string", ->
            (obj_a.name() == "").shouldBe true
        
        and_ "too", ->
            (obj_a.stereotype() == "").shouldBe true
    
    scenario "undefined for name, stereotype", ->
        it_behaves_as "create an object"
        when_it "sets undefined", ->
            obj_a.name undefined
            obj_b.stereotype undefined
        
        then_it "makes no effects", ->
            (obj_a.name() == "foo").shouldBe true
        
        and_ "too", ->
            (obj_a.stereotype() == "bar").shouldBe true
    
    scenario "null for name, stereotype", ->
        it_behaves_as "create an object"
        when_it "sets null", ->
            obj_a.name null
            obj_a.stereotype null
        
        then_it "return null", ->
            (obj_a.name() == null).shouldBe true
        
        and_ "too", ->
            (obj_a.stereotype() == null).shouldBe true
    
    scenario "partial update", ->
        it_behaves_as "create an object"
        when_it "set name", ->
            obj_a.stereotype("baz")
        
        then_it "makes no effects", ->
            (obj_a.name() == "foo").shouldBe true
        
        and_ "too", ->
            (obj_a.stereotype() == "baz").shouldBe true
    
    narrative "stereotype"
    scenario "stereotype for .message in data", ->
        given "an object and an message", ->
            @obj_a = $.uml(".object")
            @iact_aa = obj_a.activate().interact(obj_a)
            @msg_a = $.uml($(".message:eq(0)", iact_aa))[0]
        
        when_it "set stereotype to obj_a", ->
            obj_a.stereotype "actor"
        
        and_ "set stereotype to msg_a", ->
            msg_a.stereotype "asynchronous"
        
        then_it "the message has .asynchronous class", ->
            msg_a.hasClass("asynchronous").shouldBe true
    
    shared_behavior "four messages", ->
        given "messages", ->
            @diagram = $.uml(".sequence-diagram").append(obj_a = $.uml(".object"))
            diagram.appendTo $("body")
            obj_a.activate().interact(obj_a).gives(".occurrence").as(".actee").interact(obj_a).gives(".occurrence").as(".actee").interact(obj_a).gives(".occurrence").as(".actee").destroy obj_a
            @msg_a0 = diagram.$0(".message:eq(0)")
            @msg_a1 = diagram.$0(".message:eq(1)")
            @msg_a2 = diagram.$0(".message:eq(2)")
            @msg_a3 = diagram.$0(".message:eq(3)")
    
    scenario "message with stereotype method", ->
        it_behaves_as "four messages"
        when_it "give stereotype", ->
            msg_a0.stereotype "create"
            msg_a1.stereotype "asynchronous"
            msg_a2.stereotype "synchronous"
            msg_a3.stereotype "destroy"
        
        then_it "msg_a0 has .create", ->
            msg_a0.hasClass("create").shouldBe true
        
        then_it "msg_a1 has .asynchronous", ->
            msg_a1.hasClass("asynchronous").shouldBe true
        
        then_it "msg_a2 has .synchronous", ->
            msg_a2.hasClass("synchronous").shouldBe true
        
        then_it "msg_a3 has .destroy", ->
            msg_a3.hasClass("destroy").shouldBe true
    
    scenario "stereotype for interaction", ->
        it_behaves_as "four messages"
        when_it "give stereotype", ->
            diagram.$0 ".interaction:eq(0)"
            diagram.$0(".interaction:eq(1)").stereotype "create"
            diagram.$0(".interaction:eq(2)").stereotype "asynchronous"
            diagram.$0(".interaction:eq(3)").stereotype "synchronous"
            diagram.$0(".interaction:eq(4)").stereotype "destroy"
        
        then_it "msg_a0 has .create", ->
            msg_a0.hasClass("create").shouldBe true
        
        then_it "msg_a1 has .asynchronous", ->
            msg_a1.hasClass("asynchronous").shouldBe true
        
        then_it "msg_a2 has .synchronous", ->
            msg_a2.hasClass("synchronous").shouldBe true
        
        then_it "msg_a3 has .destroy", ->
            msg_a3.hasClass("destroy").shouldBe true
        
        then_it "obj_a is not affected", ->
            (obj_a.attr("class") == "object").shouldBe true
    
    scenario "__proto__", ->
        given "some objects having different type each other", ->
            @obj = $.uml(".object")
            @msg = $.uml(".message")
            @iact = $.uml(".interaction")
        
        then_it "they are not equal, obj & msg", ->
            (obj.__proto__ == msg.__proto__).shouldBe false
        
        and_ "__proto__ b/w msg & iact", ->
            (msg.__proto__ == iact.__proto__).shouldBe false
        
        and_ "__proto__ b/w iact & obj", ->
            (iact.__proto__ == obj.__proto__).shouldBe false
    
    scenario "uml object selected by selector", ->
        it_behaves_as "create an object and refers with 2ways"
        when_it "select the 2nd", ->
            @b1 = diagram.find(".object:last")
        ## wrapping is needed, it's very hard, so pending.
        xthen_it "has gives", ->
            (typeof b1.gives).shouldBe "function"

    description "script tag", ->
        it 'should TENTATIVELY change before-behavior', ->
            prefs = $.jumly[':preferences'].run_script
            save = prefs.before_compose
            prefs.before_compose = (diag, target) -> diag.prependTo target

            script = $("<script>").attr(type:"text/jumly-usecase-diagram", "target-id":"we-can-change-a-manupilator").html """
                @usecase(id:1) "an usecase"
                @actor "user":use:[1]
                """
            target = $("<div>").attr(id:"we-can-change-a-manupilator")
                               .append("<div>hello</div>")
            $("body").append target

            diag = $.jumly.run_script_ script
            expect(target.find("*:eq(0)").hasClass "diagram").toBeTruthy()  ## diag is prepended in the target.
   
            prefs.before_compose = save
    
    description "type of script, mime-type", ->
   
        it 'should accept text/jumly+<type>', ->
            prefs = $.jumly[':preferences'].run_script
            script = $("<script>").attr(type:"text/jumly+usecase", "target-id":"script-tag-mime-type").html """
                @usecase(id:1) "an usecase"
                @actor "user":use:[1]
                """
            target = $("<div>").attr(id:"script-tag-mime-type")
                               .append("<div>hello</div>")
            $("body").append target

            diag = $.jumly.run_script_ script
            expect(target.find("*:eq(0)").hasClass "diagram").toBeTruthy()  ## diag is prepended in the target.

