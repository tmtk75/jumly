xdescribe "pending,", ->
  jumly = $.jumly
  
  describe "Refering", ->
    
    it "should be used with @_", ->
      diag = jumly ".use-case-diagram"
      diag.found "", ->
        @beforeCompose (e, d) ->
          d.foobar = 1
        @afterCompose (e, d) ->
          d.bizbuz = 2 if d.foobar is 1
      diag.compose()
      expect(diag.foobar).toBe 1
      expect(diag.bizbuz).toBe 2
  
  
  describe "Curry", ->
    
    Function.prototype.curry = ->
      args = arguments
      self = this
      ->
        Array.prototype.unshift.apply arguments, args
        self.apply this, arguments
  
    it "should bind 1st arg", ->
      sum2 = (x, y)-> x + y
      expect(sum2.curry(10)(5)).toBe 15
  
    it "should bind 1st and 2nd args", ->
      mean3 = (a, b, c)-> (a + b + c)/3
      expect(mean3.curry(10, 20)(30)).toBe 20
      
    it "should bind 1st array", ->
      f = (a, b)-> a.push b; a
      expect(f.curry([1,2])(3)).toEqual [1,2,3]
  
    it "should bind instance method...", ->
      a =
        b: 2
        f: (x)-> x + this.b
      f = (obj)-> (args)-> obj.f.curry(3).apply obj, arguments
      expect(f(a)()).toBe 5
  
  
  describe "sandbox", ->
    f = (x)-> console.log kindof
    it "", ->
      f 1
  
  xdescribe "Identifiable Directive", ->
    ###
    There are a few ways to notate identified directive.
      1. @direct id_value: a:1, b:2, c:3
      2. @direct(id_value) a:1, b:2, c:3
      3. @direct(id:id_value) a:1, b:2, c:3
      4. @direct id(id_value) a:1, b:2, c:3
    ###
    it "", ->
      script = $("<script>").attr("type", "text/jumly+use-case")[0]
      $.jumly.runScript script
    
    it "should return equivalent object apart from id attribute for @usecaes", ->
      builder = new JUMLY.UsecaseBuilder
      builder ->
        @boundary "sys", ->
          @usecase(1) "Taro"
          @usecase("a2") "Jiro"
  
    it "should return equivalent object apart from id attribute for @", ->
      f = (a)-> console.log a, $.jumly.normalize a
      f name0:Taro:1,Jiro:2,Saburo:3
      f "name-123": a:2, b:3, c:1
  #    builder = new JUMLY.SequenceBuilder
  #    builder ->
  #      @found momo:"Taro":2
        
    it "", ->
      f = -> console.log arguments
      g = -> console.log arguments; ->
      f name:g("Taro") -> 1
      
  
  ###
    Here is an actual script to a description someone wrote.
    ------------------------------------------------
    <script type='text/jumly+sequence'>
    s = "I"
    a = "Shadow account"
    @found s, ->
      @create a
      @message "GET", a, -> @reply "default response"
      @message "PUT quota:1073741824, sync:true", a
      @message "GET", a, -> @reply "quota:1073741824, sync:true, usage:0"
      @message "PUT quota:4294967296, sync:true", a
      @message "GET", a, -> @reply "quota:4294967296, sync:true, usage:0"
      ## I want to change CSS here.
    @found a, ->
      @message "sync", "Teapkin", -> @message "increate usage by 1314874"
    @found s, ->
      @message "/change-password with 'foobar'", a
      @message "GET", a, -> @reply "quota:0, usage:1314874, sync:false" ## I want to mark this
      @message "PUT quota:1073741824, sync:true", a
      @message "GET", a, -> @reply "quota:0, sync:false, usage:2485732" 
  
      @beforeCompose (e, d)->
        d.find(".object").not(":eq(0)").css "margin-left":"100px"
        d.find(".interaction").css "margin-top":"40px"
    </script>
    ------------------------------------------------
    As an ideal, it's like below.
    ------------------------------------------------
    <script type='application/jumly+sequence'>
    @found server:"I", ->
      @message "GET", server, @reply "quota:xxx, ..."
      @message "PUT quota:xxx, ...", server
      @message "GET", server
    </script>
  ###
  ###
  on
  for
  in
  at
  of
  to
  from
  into
  onto
  by
  ###