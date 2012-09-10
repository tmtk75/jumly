description "uml.identification", ->
    description "jumly parameter -- identified string", ->
        f = $.jumly.normalize
        it "should accept a string", ->
            p = f "an object name"
            # {name:"an object name"}
            expect(p.id)  .toBeUndefined()
            expect(p.name).toBe "an object name"
        
        it "should accept an identified string", ->
            p = f 1:"an object name"
            # {id:1, name:"an object name"}
            expect(p.id)  .toBe 1
            expect(p.name).toBe "an object name"

        it "should accept a string with other parameters", ->
            p = f "an object name", width:100, height:200
            # {name:"an object name", width:100, height:200}
            expect(p.id)    .toBeUndefined()
            expect(p.name)  .toBe "an object name"
            expect(p.width) .toBe 100
            expect(p.height).toBe 200
        
        it "should accept an identified string with other parameters", ->
            p = f 2:"taro", length:180
            # {id:2, name:"taro", length:180}
            expect(p.id)    .toBe 2
            expect(p.name)  .toBe "taro"
            expect(p.length).toBe 180
        
        it "should accept an identified string with hex", ->
            p = f 0x10:"taro"
            expect(p.id).toBe 16
        
        it "should accept an identified string with string consisted of digit", ->
            p = f "1234":"taro"
            expect(p.id).toBe 1234
        
        it "should accept an jumly parameter", ->
            p = f id:"ID-3", name:"jiro", age:28
            # {id:2, name:"taro", length:180}
            expect(p.id)  .toBe "ID-3"
            expect(p.name).toBe "jiro"
            expect(p.age) .toBe 28

        it "is undefined for identified strings more than two", ->
            p = f 1:"first", 2:"second"

        it "takes the property named as id", ->
            p = f 1:"first", 2:"second", id:"third"
            # {id:"third", 1:"first", 2:"second"}
            expect(p.id)  .toBe "third"
            expect(p.name).toBeUndefined()
            expect(p[1])  .toBe "first"
            expect(p[2])  .toBe "second"

        it "should return null for number", ->
            p = f 1
            expect(p).toBe null

        it "should return null for array", ->
            p = f []
            expect(p).toBe null

        it "should return null for boolean", ->
            p = f 1
            expect(p).toBe null
        
        it "should return undefined for undefined", ->
            p = f undefined
            expect(p).toBe undefined
        
        it "should return null for null", ->
            p = f null
            expect(p).toBe null

    description "jumly parameter -- attributted string", ->
        it "should be composited as for attributed string", ->
            a = "Post a comment": use:[1, 2], extendee: a:1, b:2
            a["Post a comment"].use[0].shouldBe 1
            a["Post a comment"].extendee.b.shouldBe 2
        
        it "should be composited as identified string", ->
            a = 1234:"first-string": use:[1, 2], extendee: a:3, b:4
            a["1234"]["first-string"].use[0].shouldBe 1
    
    description "jumly parameter -- identified attributted string", ->
        f = $.jumly.normalize

        it "should return an array having three elements", ->
            a = {a:1, b:2, c:3}
            b = for k, v of a
                {k:k, v:v}
            b.length.shouldBe 3

        it "should return the last pair", ->
            a = {a:1, b:2, c:3}
            b = {k:k, v:v} for k, v of a
            expect(b.constructor is Array).toBeFalsy()

        it "should be identified", ->
            a = f 1234:"first-string", use:[1, 2], extendee: a:3, b:4
            a.id.shouldBe 1234
            a.name.shouldBe "first-string"
            a.use[0].shouldBe 1
            a.use[1].shouldBe 2
            a.extendee.a.shouldBe 3
            a.extendee.b.shouldBe 4

        it "should have name property for attributed string through normalize", ->
            f = $.jumly.normalize
            a = f "User": use:[1]
            a.name.shouldBe "User"
            expect(a["User"]).toBeUndefined()
            a.use[0].shouldBe 1

    description "identity return ID value or null", ->
        ident = $.jumly.identify
        it "should return 123 for 123", ->
            expect(ident id:123).toBe 123
        it "should return 555.01234 for 555.01234", ->
            expect(ident id:555.01234 ).toBe 555.01234
        it "should return 'abc'", ->
            expect(ident id:"abc").toBe 'abc'
        it "should return '345'", ->
            expect(ident id:->345).toBe 345
        it "should return null for them", ->
            expect(ident id:true).toBe null
            expect(ident id:false).toBe null
            expect(ident id:[]).toBe null
            expect(ident id:{}).toBe null
            expect(ident id:undefined).toBe null
            expect(ident id:null).toBe null

