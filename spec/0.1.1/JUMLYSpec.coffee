describe "JUMLY", ->
  it "should be in window scope", ->
    expect(window.JUMLY).not.toBeUndefined()

  it "should provide class hierarchy for JUMLY library"
    
  describe "@self", ->
    it "should return ownself", ->
      a = $.jumly ".usecase-diagram"
      expect(a.self()).not.toBeUndefined()
      expect(a.self()).toBe a
    
  describe "Naming", ->
    describe "toID", ->
      toID = JUMLY.Naming.toID
      
      it "should convert all ASCII chars to lower-case", ->
        expect(toID("aAzZ")).toBe "aazz"      
        
      it "should keep all digits", ->
        expect(toID("0123456789_")).toBe "0123456789_"      
        
      it "should convert all characters apart from ASCII and digits to '-' hyphen", ->
        expect(toID("!\"#$%&'()[]^<>?+*{}|`@~=,./_")).toBe "---------------------------_"
        
      it "should return id attribute value for jQuery object", ->
        id = "Naming-toID-identified-jQuery-object"
        div = $("<div>").attr id:id
        expect(toID div).toBe id

      it "should return 'undefined' for not identified HTMLElement", ->
        div = $("<div>")
        expect(toID div).toBe undefined


    describe "toRef", -> ## about Ref@diagram
      it "should be rule that Ref value consists of [a-z_][a-z0-9_] in regular expression"
      toRef = JUMLY.Naming.toRef

      it "should be converted for hyphen '-' to underscore '_'", ->
        expect(toRef "-").toBe '_'
        expect(toRef "-0").toBe '_0'
        expect(toRef "-1").toBe '_1'
        expect(toRef "a-b").toBe 'a_b'

      it "should be converted for digit [0-9] in head to '_'", ->
        expect(toRef "0").toBe '_0'
        expect(toRef "01").toBe '_01'

      it "should be converted for string starts with digit like 0,1 to be prepended '_' like _0,_1", ->
        expect(toRef "0").toBe '_0'
        expect(toRef "1").toBe '_1'

    describe "isID", ->
      it "should be represented with a regular expression `^[a-zA-Z0-9_\-]+$`"
      
    describe "toCSSClass", ->
      toCSS = JUMLY.Naming.toCSSClass
      it "should remove JUMLY in head", ->
        expect(toCSS "JUMLYClass").toBe "class"

      it "should convert all to lowercase", ->
        expect(toCSS "JUMLYMETHOD").toBe "method"

      it "should insert '-' before 'Diagram'", ->
        expect(toCSS "JUMLYFooDiagram").toBe "foo-diagram"



  describe "Identity", ->
    describe "normalize", ->
      normalize = JUMLY.Identity.normalize
      
      it "is assumption for syntax in CoffeeScript", ->
        a = ID:You:have:dogs:["jack", "fred"], on:"desk", at:"room"
        dogs = a.ID.You.have.dogs
        expect(dogs[0]).toBe "jack"
        expect(dogs[1]).toBe "fred"
        expect(a.ID.You.have.on).toBe "desk"
        expect(a.ID.You.have.at).toBe "room"

      it "should be ID and name for string", ->
        a = normalize "You"
        expect(a.id  ).toBe "you"
        expect(a.name).toBe "You"

      it "should be ID and name for identified string", ->
        a = normalize ID:"You"
        expect(a.id  ).toBe "ID"
        expect(a.name).toBe "You"

      it "should be ID and name for identified phrase", ->
        a = normalize ID:You:have:null
        expect(a.id  ).toBe "ID"
        expect(a.name).toBe "You"
        expect(a.have).toBeNull()

      it "should be ID and name for identified phrase with object", ->
        a = normalize ID:You:have:dogs:["jack", "fred"]
        expect(a.id  ).toBe "ID"
        expect(a.name).toBe "You"
        expect(a.have.dogs).toEqual ["jack", "fred"]
        
      it "should be ID and name for a JUMLY value", ->
        a = normalize ID:You:have:dogs:["jack", "fred"],on:"desk",at:"room"
        expect(a.id  ).toBe "ID"
        expect(a.name).toBe "You"
        expect(a.have.dogs).toEqual ["jack", "fred"]
        expect(a.have.on).toBe "desk"
        expect(a.have.at).toBe "room"

      it "should be ID and name for another JUMLY value", ->
        a = normalize ID:You:have:(dogs:["jack", "fred"]),on:"desk",at:"room"
        expect(a.id  ).toBe "ID"
        expect(a.name).toBe "You"
        expect(a.have.dogs).toEqual ["jack", "fred"]
        expect(a.on).toBe "desk"
        expect(a.at).toBe "room"

      it "should be that as is for object having more than two keys", ->
        a = normalize ID:(You:1), on:"desk"
        expect(a.id).toBeUndefined()
        expect(a.ID).toEqual You:1
        expect(a.on).toBe "desk"

      it "should be that as is for name having more than two keys", ->
        a = normalize She:{age:12, eye:"black"}
        expect(a.id).toBe "she"
        expect(a.name).toBe "She"
        expect(a.age).toBe 12
        expect(a.eye).toBe "black"

      it "should be usual form with ID", ->
        a = normalize ID:Me:{age:8, eye:"green"}
        expect(a.id).toBe "ID"
        expect(a.name).toBe "Me"
        expect(a.age).toBe 8
        expect(a.eye).toBe "green"

      it "should be usual form without ID", ->
        a = normalize Me:{age:8, eye:"green"}
        expect(a.id).toBe "me"
        expect(a.name).toBe "Me"
        expect(a.age).toBe 8
        expect(a.eye).toBe "green"

      it "should be ID for number", ->
        a = normalize 123:He:{race:"US"}
        expect(a.id).toBe "123"
        expect(a.name).toBe "He"
        expect(a.race).toBe "US"

      it "should be no ID for the form that 3rd is Array", ->
        think = {}
        render = {}
        a = normalize User:use:[think, render]
        expect(a.id).toBe "user"
        expect(a.name).toBe "User"
        expect(a.use).toEqual [think, render]

      it "should not be undefined", ->
        a = normalize "update file": use: ->
        expect(a).not.toBeUndefined()
        expect(a.name).toBe "update file"
        expect(a.use).not.toBeUndefined()

    
describe "$.jumly", ->
  it "should provide public interface for user"
