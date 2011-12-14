u = $.jumly
description "usecase.DSL", ->

    description "@beforeCompose", ->

        it "should run a closure before composing", ->
            diag = u ".usecase-diagram"
            diag.boundary "", ->
                @beforeCompose (e, d) ->
                    d.foobar = 1
                @afterCompose (e, d) ->
                    d.bizbuz = 2 if d.foobar is 1
            diag.compose()
            expect(diag.foobar).toBe 1
            expect(diag.bizbuz).toBe 2
   

    description "@afterCompose", ->
   
        it "should run a closure after composing", ->
            diag = u ".usecase-diagram"
            counter = 0
            diag.boundary "", ->
                @afterCompose (e, d) ->
                    counter = 1
            diag.compose()
            expect(counter).toBe 1

    description "@usecase", ->
        scenario "register and identification", ->
            given "a usecase diagram", -> @diag = $.uml ".usecase-diagram"
            and_ "an usecase", ->
                diag.boundary "1st boundary", ->
                    @usecase "Open File"

        scenario "having stereotypes in array declared with string", ->
            given "a usecase diagram", -> @diag = $.uml ".usecase-diagram"
            given "an usecase", ->
                diag.boundary "2nd boundary", ->
                    @usecase "Close File":{extend:["Open File"]}
                
        scenario "having stereotypes in array declared with array", ->
            given "a usecase diagram", -> @diag = $.uml ".usecase-diagram"
            given "an usecase", ->
                diag.boundary "a boundary", ->
                    @usecase "Close File":{extend:["Open File", "Close Socket"]}
            then_it "has two extends", ->
                a = diag.find(".usecase:eq(0)").self()
                a.data("uml:property").extend[0].shouldBe "Open File"
                a.data("uml:property").extend[1].shouldBe "Close Socket"
                
    description "@actor", ->
        scenario "register and identification", ->
            given "a usecase diagram", -> @diag = $.uml ".usecase-diagram"
            and_ "an actor", ->
                diag.boundary "1st boundary", ->
                    @actor "Hiroshi"

        scenario "actor, too", ->
            given "a usecase diagram", -> @diag = $.uml ".usecase-diagram"
            given "an usecase", ->
                diag.boundary "a boundary", ->
                    @actor "Manager":{extend:["User", "Viewer"]}
            then_it "has two extends for .actor", ->
                a = diag.find(".actor:eq(0)").self()
                a.data("uml:property").extend[0].shouldBe "User"
                a.data("uml:property").extend[1].shouldBe "Viewer"
                
    description ".include", ->
        scenario "include for usecase", ->
            given "a usecase diagram", -> @diag = $.uml ".usecase-diagram"
            given "an usecase", ->
                diag.boundary "a boundary", ->
                    @usecase "Open File":{include:["Find File"]}
            then_it "it has a include", ->
                a = diag.find(".usecase:eq(0)").self()
                a.data("uml:property").include[0].shouldBe "Find File"
    
    description "@boundary", ->

        it 'should accept undefined', ->
            ($.uml ".usecase-diagram").boundary undefined, ->

        scenario "", ->
            given "a usecase diagram", -> @diag = $.uml ".usecase-diagram"
            given "some boundaries", ->
                diag.boundary "a", ->
                    @boundary "b", ->
                .boundary "c", ->
                    @boundary "d", ->
                    @boundary "e", ->
            when_it "compose", ->
                diag.appendTo $ "body"
                diag.compose()
            then_it "totaly five boundary", ->
                diag.find(".system-boundary").length.shouldBe 5
            and_ ->
                diag.find("> .system-boundary:eq(0)").expect(name:"a")
                        .find(".system-boundary:eq(0)").expect(name:"b")
                diag.find("> .system-boundary:eq(1)").expect(name:"c")
                        .find(".system-boundary:eq(0)").expect(name:"d").end()
                        .find(".system-boundary:eq(1)").expect(name:"e").end()

    description "@usecase", ->
        shared_scenario "simple string", ->
            given "a usecase diagram", ->
                @diag = $.uml ".usecase-diagram"
            and_ "a boundary and an usecase", ->
                diag.boundary "a", ->
                    @usecase "open file"
            then_it "the name is defined", ->
                diag.find(".usecase:last .name").text().shouldBe "open file"

        shared_scenario "attributed string", ->
            given "a boundary and an usecase", ->
                diag.boundary "b", ->
                    @usecase "update file": use: ->
            then_it "the name is defined", ->
                diag.find(".usecase:last .name").text().shouldBe "update file"

        shared_scenario "identified attributed string", ->
            given "a new usecase", ->
                diag.boundary "b", ->
                    @usecase 1234:"close file": extend:[1, 2]
            xthen_it "the name is defined", ->
                diag.find(".usecase:last .name").text().shouldBe "close file"

        u = $.jumly
        scenario "has extend property in this:property", ->
            given "an usecase", ->
                @uses = []
                @exts = []
                @foobars = []
                ctxt = u(".usecase-diagram").boundary "b", ->
                    @usecase "a uc": use:uses, extend:exts, foobar:foobars
                @uc_ = ctxt._diagram.find(".usecase:last").self()
                @props = uc_.data("uml:property")
            then_it "props is defiened", ->
                expect(props).toBeDefined()
            and_ "use in this:property", ->
                expect(props.use).toBe uses
            and_ "extend in this:property", ->
                expect(props.extend).toBe exts
            and_ "foobar in this:property", ->
                expect(props.foobar).toBe foobars
            and_ "use", ->
                expect(uc_.use).toBeUndefined()
            and_ "extend is a function", ->
                expect(typeof uc_.extend).toBe "function"  ## This is $.extend.
            and_ "foobar is not defined", ->
                expect(uc_.foobar).toBeUndefined()

        p = u.normalize
        it "should return a closure for given an identification object", ->
            expect(typeof p id:1234).toBe "object"

        it "should have id, name", ->
            a = p id:1234, name:"he"
            expect(a.id).toBe 1234
            expect(a.name).toBe "he"

        it "should have id, use", ->
            a = p id:2345, use:"flow"
            expect(a.id).toBe 2345
            expect(a.name).toBeUndefined()
            expect(a.use).toBe "flow"

        u = $.jumly
        p = u.normalize
       
        uc = null
        u(".usecase-diagram").boundary "b", ->
            #@deprecated: v0.1.0 feature
            #uc = (@usecase(id:"this value is set in 'id' attribute") "attr str": a:1, b:2, c:3).find(".usecase:eq(0)").self()
        #@deprecated: v0.1.0 feature
        xit "should be basic spec for @usecase identified by string", ->
            expect(uc.attr "id").toBe "this value is set in 'id' attribute"
            props = uc.data("uml:property")
            expect(props.name).toBe "attr str"
            expect(props.a).toBe 1
            expect(props.b).toBe 2
            expect(props.c).toBe 3
            
        #@deprecated v0.1.0 feature
        xscenario "identification", ->
            given "an usecase", ->
                @uses = []
                ctxt = u(".usecase-diagram").boundary "b", ->
                    @usecase(id:1234) "a uc 1": use:uses
                    @usecase(id:"TA-0") "a uc 0": use:uses
                    @actor(id:"AC-2") "User": use:[1234, "TA-0"], id:"abc"
                @u0 = ctxt._diagram.find(".usecase:eq(0)").self()
                @u1 = ctxt._diagram.find(".usecase:eq(1)").self()
                @a0 = ctxt._diagram.find(".actor:eq(0)")   .self()
            then_it "identified with 1234", ->
                expect(@u0.attr "id").toBe '1234'
            and_ ->
                expect(@u0.data("uml:property").id).toBe 1234
            then_it "identified with 'TA-0'", ->
                expect(@u1.attr "id").toBe 'TA-0'
            and_ ->
                expect(@u1.data("uml:property").id).toBe 'TA-0'
            then_it "identified with 'AC-2'", ->
                expect(@a0.attr "id").toBe 'AC-2'
            and_ ->
                expect(@a0.data("uml:property").id).toBe 'AC-2'

        #@deprecated: v0.1.0 feature
        xit "should be created", ->
            uc = null
            $.jumly(".usecase-diagram").boundary "b", ->
                uc = (@usecase(id:1234) "a uc 1": use:"--!").find(".usecase:eq(0)")
            props = uc.data "uml:property"
            expect(uc).toBeDefined()
            expect(props).toBeDefined()
            expect(props.use).toBe "--!"
            expect(uc.attr "id").toBe '1234'
            expect(props["id"]).toBe 1234
            expect(props.name).toBe "a uc 1"

        #@deprecated: v0.1.0 feature
        xit "should have use & foo propertes", ->
            uc = null
            $.jumly(".usecase-diagram").boundary "b", ->
                uc = (@usecase(id:1) "Take it", use:[2, 3], foo:[1]).find ".usecase:eq(0)"
            props = uc.data "uml:property"
            props.name.shouldBe "Take it"
            props.use.length.shouldBe 2
            props.foo.length.shouldBe 1

    description "script tag", ->

        it 'is able to write a DSL like', ->
            script = $("<script>").html """
                @usecase "an usecase"
                @usecase "another usecase"
                """
            diag = $.jumly.DSL('.usecase-diagram').compileScript script
            diag.find(".usecase").expect length:2

        #@deprecated: v0.1.0 feature
        xit 'is able to embed to a node with target-id attribute', ->
            script = $("<script>").attr(type:"text/jumly-usecase-diagram", "target-id":"placeholder-to-embed").html """
                @usecase(id:1) "an usecase"
                @actor "user":use:[1]
                """
            target = $("<div>").attr(id:"placeholder-to-embed")
            $("body").append target
            diag = $.jumly.run_script_ script
            target.find(".diagram").expect(length:1)
                  .find(".usecase").expect(length:1).end()
                  .find(".actor").expect(length:1).end()
                  .find(".relationship").expect(length:1).end()
            target.find("> .diagram").expect(length:1)

        it '@afterCompose in <script>', ->
            script = $("<script type='text/jumly-usecase-diagram'>").html """
                @usecase 1:"A"
                @usecase "B_af":extend:[1]
                @actor "C_af":use:[1]
                @afterCompose (e, d) ->
                    d.foobar = true
                """
            diag = $.jumly.run_script_ script
            expect(diag.foobar).toBeTruthy()
            
        it 'is an .out-of-bounds', ->
            script = $("<script>").html """
                @actor "me"
                @actor "you"
                @usecase "an usecase"
                @usecase "another usecase"
                @boundary "an boundary", ->
                    @usecase "an inner usecase"
                """
            diag = $.jumly.DSL('.usecase-diagram').compileScript script
            diag.find("> .out-of-bounds > .usecase").expect length:2
            diag.appendTo $ "body"
            diag.compose()
           
            # style is similar to none
            oob = diag.find("> .out-of-bounds")
            oob.css("border-width").shouldBe ""
            oob.css("border-color").shouldBe ""
            oob.css("box-shadow").shouldBe "none"
            oob.css("-webkit-box-shadow").shouldBe "none"

            # size
            oob.outerWidth().shouldBeGreaterThan 0   # depends on window size
            oob.outerHeight().shouldBeGreaterThan 0  # depends on total of icons.

            # doesn't have .name
            oob.find("> .name").length.shouldBe 0


        it 'is .out-of-bounds in case of no system-boundary-name attribute', ->
            script = $("<script>").html """
                @actor "you"
            """
            diag = $.jumly.DSL('.usecase-diagram').compileScript script
            expect(diag.find("> .out-of-bounds").length).toBe 1
            expect(diag.find("> .system-boundary").length).toBe 0

        it 'is .system-boundary in case having system-boundary-name attribute', ->
            script = $("<script system-boundary-name='a boundary'>").html """
                @actor "you"
            """
            diag = $.jumly.DSL('.usecase-diagram').compileScript script
            expect(diag.find("> .out-of-bounds").length).toBe 0
            expect(diag.find("> .system-boundary").length).toBe 1
            expect(diag.find("> .system-boundary > .name").text()).toBe "a boundary"

