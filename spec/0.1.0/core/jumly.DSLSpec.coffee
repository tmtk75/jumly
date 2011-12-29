u = $.jumly
description "jumly.DSL", ->

    description "@beforeCompose", ->

        it "should run a closure before composing", ->
            diag = u ".sequence-diagram"
            diag.found "Need something name", ->
                @beforeCompose (e, d) ->
                    d.foobar = 1
                @afterCompose (e, d) ->
                    d.bizbuz = 2 if d.foobar is 1
            diag.compose()
            expect(diag.foobar).toBe 1
            expect(diag.bizbuz).toBe 2

    description "@afterCompose", ->

        it "should run a closure after composing", ->
            diag = u ".sequence-diagram"
            holder = null
            counter = 0
            diag.found "Need something name 1", ->
                @afterCompose (e, d) ->
                    holder = d
                    counter += 1

            diag.compose()
            expect(diag).toBe holder
            expect(counter).toBe 1

            diag.compose()
            expect(counter).toBe 2


    description "@preferences", ->
   
        it "should be set every instance", ->
            diag = u ".sequence-diagram"
            diag.found "Need something name-1", -> @preferences compose_most_left:0, compose_span:48
            prefs = diag.preferences()
            prefs.compose_most_left.shouldBe 0
            prefs.compose_span.shouldBe 48
        
        it "should be not changed from before", ->
            diag = u ".sequence-diagram"
            prefs = diag.preferences(".sequence-diagram")
            expect(prefs.WIDTH ).toBeDefined()
            expect(prefs.HEIGHT).toBeDefined()

        it "should return the same instance every call", ->
            a = $.jumly.preferences(".sequence-diagram")
            b = $.jumly.preferences(".sequence-diagram")
            expect(a).toBe b

        it "should return different instance every call", ->
            diag = u ".sequence-diagram"
            a = diag.preferences()
            b = diag.preferences()
            expect(a).toNotBe b

        it "should be set for all instances of .sequence-diagram", ->
            oldone = u ".sequence-diagram"
            oldprefs = oldone.preferences()
            
            prefs = $.jumly.preferences(".sequence-diagram")
            old = most_left:prefs.compose_most_left, span:prefs.compose_span
            prefs.compose_most_left = 0
            prefs.compose_span      = 48
            
            newone = u ".sequence-diagram"
            newprefs = newone.preferences()
            
            oldprefs.compose_most_left.shouldBe old.most_left
            oldprefs.compose_span     .shouldBe old.span
            newprefs.compose_most_left.shouldBe 0
            newprefs.compose_span     .shouldBe 48
            expect(oldprefs).toNotBe newprefs


    shared_scenario 'registeration for a DSL', ->
        given "a compiler (which is just a function)", ->
        when_it "register it", ->
            $.jumly.DSL type:'.hello-world', version:'0.0.1', compileScript: -> "Hello World"
        then_it "return a result", ->
            compiler = ($.jumly.DSL '.hello-world')
            a = compiler.compileScript "something"
            expect(compiler.version).toBe '0.0.1'
            expect(a).toBe 'Hello World'
    
    scenario "latest DSL use", ->
        it_behaves_as "registeration for a DSL"
        when_it "register a new DSL", ->
            $.jumly.DSL type:'.hello-world', version:'0.0.2', compileScript: -> "Stay hungry, Stay foolish"
        then_it "return a result", ->
            compiler = ($.jumly.DSL '.hello-world')
            a = compiler.compileScript "something"
            expect(compiler.version).toBe '0.0.2'
            expect(a).toBe 'Stay hungry, Stay foolish'


    description "irregular arguments", ->

        it "can't accept null", -> expect(-> $.jumly.DSL null).toThrow("It MUST NOT be null.")
        
        it "can't accept undefined", -> expect(-> $.jumly.DSL undefined).toThrow()

        it "can't accept boolean", -> expect(-> $.jumly.DSL true).toThrow()
        
        it "can't accept Array", -> expect(-> $.jumly.DSL []).toThrow()
        
        it "can't accept number", -> expect(-> $.jumly.DSL 123).toThrow()


