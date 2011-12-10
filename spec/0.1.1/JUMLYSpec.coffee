describe "JUMLY", ->
  it "should be in window scope", ->
    expect(window.JUMLY).not.toBeUndefined()

  it "should provide class hierarchy for JUMLY library"
    
  describe "Naming", ->
    
    describe "toID", ->
      toID = JUMLY.Naming.toID
      
      it "should convert all ASCII chars to lower-case", ->
        expect(toID("aAzZ")).toBe "aazz"      
        
      it "should keep all digits", ->
        expect(toID("0123456789_")).toBe "0123456789_"      
        
      it "should convert all characters apart from ASCII and digits to '-' hyphen", ->
        expect(toID("!\"#$%&'()[]^<>?+*{}|`@~=,./_")).toBe "---------------------------_"
  

    describe "isID", ->
      
      it "should be represented with a regular expression `^[a-zA-Z0-9_\-]+$`"


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
        a = normalize ID:{age:12, eye:"black"}
        expect(a.id).toBe "ID"
        expect(a.name).toBeUndefined()
        expect(a.age).toBe 12
        expect(a.eye).toBe "black"


describe "$.jumly", ->
  it "should provide public interface for user"
