description "uml:property", ->
    u = $.uml
    shared_scenario "stereotype CRUD, Create/Read", ->
        given "an object", ->
            @a = u ".object"
            @b = u ".object"
        when_it "add a stereotype", ->
            @a.addClass "abstract"
        then_it "@a has the stereotype", ->
            # LEGACY: @a.data("uml:property").stereotypes().length.shouldBe 1
            # LEGACY: @a.hasStereotype("abstract").shouldBeTruthy()
            @a.hasClass("abstract").shouldBeTruthy()
        then_it "@b doesn't have stereotype", ->
            @b.data("uml:property").stereotypes().length.shouldBe 0

    shared_scenario "stereotype CRUD, Add more", ->
        it_behaves_as "stereotype CRUD, Create/Read"
        when_it "add a stereotype", ->
            @a.addClass "mutable"
        then_it "@a has the multiple stereotypes()", ->
            #@a.data("uml:property").stereotypes().length.shouldBe 2
        and_ ->
            # LEGACY: @a.hasStereotype("abstract").shouldBeTruthy()
            @a.hasClass("abstract").shouldBeTruthy()
        and_ ->
            # LEGACY: @a.hasStereotype("mutable").shouldBeTruthy()
            @a.hasClass("mutable").shouldBeTruthy()
            

    shared_scenario "found and create", ->
        given "some objects", ->
            @diag = $.uml ".sequence-diagram"
            diag.found "A", ->
                @create "B"
            @a = @diag.data "uml:property"
            @b = @diag.A.data "uml:property"
            @c = @diag.B.data "uml:property"
            @d = @diag.find(".message:last").self().data "uml:property"
        then_it "has name for @a", -> expect(@a.name).toBeDefined()
        and_    "has name for @b", -> expect(@b.name).toBeDefined()
        and_    "has name for @c", -> expect(@c.name).toBeDefined()
        and_    "has name for @d", -> expect(@d.name).toBeDefined()
        #then_it "has name for @a", -> expect(@a.name).toBeDefined()
        and_    "has name for @b", -> expect(@b.name).toBe "A"
        and_    "has name for @c", -> expect(@c.name).toBe "B"
        #and_    "has name for @d", -> expect(@d.name).toBeDefined()
        #then_it "has stereotypes() for @a", -> expect(@a.stereotypes()).toBeDefined()
        #and_    "has stereotypes() for @b", -> expect(@b.stereotypes()).toBeDefined()
        #and_    "has stereotypes() for @c", -> expect(@c.stereotypes()).toBeDefined()
        #and_    "has stereotypes() for @d", -> expect(@d.stereotypes()).toBeDefined()
        #then_it "has stereotypes() for @a", -> expect(0).toBe @a.stereotypes().length
        #and_    "has stereotypes() for @b", -> expect(0).toBe @b.stereotypes().length
        #and_    "has stereotypes() for @c", -> expect(0).toBe @c.stereotypes().length
        #and_    "has stereotypes() for @d", -> expect(1).toBe @d.stereotypes().length
        then_it "has type for @a", -> expect(@a.type).toBeDefined()
        and_    "has type for @b", -> expect(@b.type).toBeDefined()
        and_    "has type for @c", -> expect(@c.type).toBeDefined()
        and_    "has type for @d", -> expect(@d.type).toBeDefined()
        then_it "has the type @a", -> expect(".sequence-diagram").toBe @a.type
        and_    "has the type @b", -> expect(".object")          .toBe @b.type
        and_    "has the type @c", -> expect(".object")          .toBe @c.type
        and_    "has the type @d", -> expect(".message")         .toBe @d.type

    description "streotype", ->
        it "has stereotype property", ->
            diag = $.uml ".sequence-diagram"
            diag.found "A", -> @create "B"
            msg = (diag.find ".message:last").self()
            (msg.hasClass "create").shouldBeTruthy()
            #msg.data("uml:property").stereotypes().length.shouldBe 1
        
    description "name", ->
        it "has name property", ->
            diag = $.uml ".sequence-diagram"
            diag.found "A", -> @message "call", "B"
            msg = (diag.find ".message:last").self()
            #msg.data("uml:property").name.shouldBe "call"

