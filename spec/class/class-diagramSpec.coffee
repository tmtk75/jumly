u = $.jumly
mkdiag = ->
    diag = u ".class-diagram"
    diag.appendTo $ "body"
    diag

description "class-diagram", ->

    description "instanciation", ->


    description "width", ->

        it "should be greater than zero", ->
            diag = mkdiag()
            
            diag.append u ".class", "foobar"
            diag.compose()

            diag.width().shouldBeGreaterThan 0
            diag.width().shouldBeGreaterThan diag.find(".class .icon").width()


    description "height", ->

        it "should be greater than zero", ->
            diag = mkdiag()
            
            diag.append u ".class", "foobar"
            diag.compose()

            diag.height().shouldBeGreaterThan 0
            diag.height().shouldBeGreaterThan diag.find(".class .icon").height()


    description "method", ->


    description "DSL", ->



