u = $.jumly
description "class.DSL", ->

    description "@afterCompose", ->
    
        it "should run a closure before composing", ->
            diag = u ".class-diagram"
            diag.found "", ->
                @beforeCompose (e, d) ->
                    d.foobar = 1
                @afterCompose (e, d) ->
                    d.bizbuz = 2 if d.foobar is 1
            diag.compose()
            expect(diag.foobar).toBe 1
            expect(diag.bizbuz).toBe 2
 

    description "@afterCompose", ->
        
        it "should run a closure after composing", ->
            diag = u ".class-diagram"
            counter = 0
            diag.boundary "", ->
                @afterCompose (e, d) ->
                    counter = 1
            diag.compose()
            expect(counter).toBe 1

