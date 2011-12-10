describe "JUMLY.Naming", ->
  
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
