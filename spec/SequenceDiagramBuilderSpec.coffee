utils = require "./jasmine-utils"

SequenceDiagramBuilder = require "SequenceDiagramBuilder"

prepare_builder = ->
  @builder = new SequenceDiagramBuilder
  @diagram = @builder.diagram()
  utils.matchers this

describe "SequenceDiagramBuilder", ->

  beforeEach prepare_builder

  describe "diagram", ->

    it "returns diagram", ->
      expect(@builder.diagram()).haveClass "diagram"
  
  describe "found", ->

    it "gives an object having .found", ->
      @builder.found "biz"
      obj = @diagram.find ".object"
      expect(obj.length).toBe 1
      expect(obj).haveClass "found"
      expect(obj.find(".name").text()).toBe "biz"

    #describe "_id",->
    #  it "is given", ->
    #    expect((@builder.build "@found 'a b'").find("#a-b").length).toBe 1

    describe "_ref", ->
      it "is given", ->
        @builder.build """
          @found 'a b'
          @_name = a_b.find(".name").text()
          """
        expect(@diagram['a_b']).toBeDefined()
        expect(@builder._name).toBe 'a b'
    
  describe "message", ->

    beforeEach ->
      @builder.found("foo")
              .message "call", "bar"
  
    it "returns itself", ->
      expect(@builder.found("foo").message "call").toBeDefined()
    
    it "gives an interaction and an occurrence", ->
      iact = @diagram.find "> .interaction"
      expect(iact.length).toBe 1
      expect(iact.find("> .occurrence").length).toBe 1
      expect(iact.find("> .occurrence > .interaction").length).toBe 1
      expect(iact.find("> .occurrence > .interaction > .message").length).toBe 1

    describe "nesting", ->

      beforeEach prepare_builder

      it "returns back to previous occurrence", ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "1-1", "b-1", ->
            @message "2", "c", ->
              @message "2-1", "c-1", ->
          """
        
        expect((diag.find "> .interaction").length).toBe 1
        expect((iacts = diag.find """
          > .interaction
            > .occurrence
              > .interaction
          """).length).toBe 2  ## including msg 1 and 2

        occur0 = iacts.filter(":eq(0)").find "> .occurrence"
        occur1 = iacts.filter(":eq(1)").find "> .occurrence"
        expect(occur0.find("> .interaction > .message").text()).toBe "1-1"
        expect(occur1.find("> .interaction > .message").text()).toBe "2-1"

    describe "twice", ->

      beforeEach prepare_builder

      it "makes two parallel interactions", ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b"
            @message "2", "c"
          """
        sel = "> .interaction:eq(0) > .occurrence:eq(0)"
        expect("1").toBe diag.find("#{sel} > .interaction:eq(0) > .message .name").text()
        expect("2").toBe diag.find("#{sel} > .interaction:eq(1) > .message .name").text()

      it "makes two nested interations", ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "2", "c"
          """
        expect("2").toBe diag.find("
          > .interaction:eq(0)
            > .occurrence:eq(0)
              > .interaction:eq(0)
                > .occurrence:eq(0)
                  > .interaction:eq(0)
                    > .message .name
          ").text()

    describe "asynchronous", ->
      it "has one .asynchronous", ->
        diag = (new SequenceDiagramBuilder).build """
          @found "a", ->
            @message asynchronous:"c", "b"
          """
        a = diag.find(".asynchronous")
        expect(a.length).toBe 1

  describe "create", ->

    beforeEach ->
      diag = @builder.build """
        @found 'a', ->
          @create 'b'
        """
      @create = diag.find(".create").data "_self"

    it "makes a .create", ->
      expect(@create.length).toBe 1

    describe "message", ->
      describe "name", ->

        it "is ''", ->
          expect(@create.find(".name").text()).toBe ""

      describe "to the created object just after @create", ->
        it "creates an .object", ->
          @builder.diagram().find("*").remove()
          diag = @builder.build """
            @found "HTTP Server", ->
              @create "HTTP Session"
              @message "save state", "HTTP Session"
            """
          expect(diag.find(".object").length).toBe 2

      describe "asynchronous", ->
        it "has one .asynchronous", ->
          diag = (new SequenceDiagramBuilder).build """
            @found "a", ->
              @create asynchronous:"b"
            """
          a = diag.find(".message.asynchronous")
          expect(a.length).toBe 1

  describe "destroy", ->

  describe "reply", ->
  
    describe "returning back to the caller", ->
 
      beforeEach ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "2", "c", ->
                @reply "2'", "b"
              @reply "1'", "a"
          """
        @iact1 = diag.find "> .interaction:eq(0) > .occurrence:eq(0) > .interaction:eq(0)"
        @iact2 = @iact1.find "> .occurrence:eq(0) > .interaction:eq(0)"
     
      it "makes a new .message with .return", ->
        expect(@iact1.find("> .message:eq(0)").text()).toBe "1"
        expect(@iact1.find("> .message:eq(1)")).haveClass "return"
        
        expect(@iact2.find("> .message:eq(0)").text()).toBe "2"
        expect(@iact2.find("> .message:eq(1)")).haveClass "return"

    describe "returning back to the ancestor", ->

      beforeEach ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "2", "c", ->
                @reply "2'", "a"
              @reply "1'", "a"
          """
        @iact1 = diag.find "> .interaction:eq(0) > .occurrence:eq(0) > .interaction:eq(0)"
        @iact2 = @iact1.find "> .occurrence:eq(0) > .interaction:eq(0)"
    
      it "makes a new .message with .return", ->
        expect(@iact1.find("> .message:eq(0)").text()).toBe "1"
        expect(@iact1.find("> .message:eq(1)")).haveClass "return"
        
        expect(@iact2.find("> .message:eq(0)").text()).toBe "2"
        expect(@iact2.find("> .message:eq(1)")).haveClass "return"

  describe "ref", ->
    
    it "contains all kids", ->
      diag = @builder.build """
        @found "open", ->
          @ref "see"
        """
      expect(diag.find(".interaction + .ref").length).toBe 1

  describe "loop", ->
    
    it "contains all kids", ->
      diag = @builder.build """
        @found "open", ->
          @loop ->
            @message "exists?", "File"
            @message "write", "File"
        """
      expect(diag.find(".loop .message").length).toBe 2
      expect(diag.find(".loop .message:eq(0)").text()).toBe "exists?"
      expect(diag.find(".loop .message:eq(1)").text()).toBe "write"

  describe "alt", ->

    describe ".alt and .name", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "open", ->
            @alt {
              "[found]": -> @message "write", "File"
              "[missing]": -> @message "close", "File"
            }
          """
        @alt = @diagram.find(".alt").data "_self"

      it "has .alt", ->
        expect(@alt.length).toBe 1

      it "has empty .name", ->
        expect(@alt.find(".name:eq(0)").text()).toBe 'alt'

    describe "NOP function", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "open", ->
            @alt {
              "[found]": ->
            }
            """
      
      it "has .alt", ->
        expect(@diagram.find(".alt").length).toBe 1

    describe "containing three parts", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "open", ->
            @alt {
              "[a]": -> @message "exists?", "File"
              "[b]": -> @message "open", "File"
              "[c]": -> @message "close", "File"
            }
          """

      it "has three .messages", ->
        expect(@diagram.find(".message").length).toBe 3

    describe "containing two .messages in a part", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "open", ->
            @alt {
              "[found]": ->
                @message "open", "Cache"
                @message "write", "Cache"
              "[missing]": ->
                @message "query", "Database"
            }
          """

      it "has two .messages", ->
        found   = @diagram.find(".condition:eq(0) ~ .interaction")
        missing = @diagram.find(".condition:eq(1) ~ .interaction")
        expect(found.length).toBe 3
        expect(missing.length).toBe 1
        expect(found.filter(":eq(0)").text()).toBe "open"
        expect(found.filter(":eq(1)").text()).toBe "write"
        expect(found.filter(":eq(2)").text()).toBe "query"
        expect(missing.filter(":eq(0)").text()).toBe "query"

    describe "containing @loop", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "open", ->
            @alt {
              "[found]": ->
                @loop -> @message "write", "File"
                @message "move", "File"
              "[missing]": -> @message "close", "File"
            }
          """

      it "works properly", ->
        expect(@diagram.find(".loop").length).toBe 1
        expect(@diagram.find(".loop ~ .interaction .message:eq(0)").text()).toBe "move"
        expect(@diagram.find(".loop ~ .interaction .message:eq(1)").text()).toBe "close"

    describe "containing @ref", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "open", ->
            @alt {
              "[missing]": ->
                @ref "that func"
            }
          """

      it "works properly", ->
        expect(@diagram.find(".ref").length).toBe 1

  describe "reactivate", ->

  describe "lost", ->
  
  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node).haveClass "diagram"

    describe "found", ->

      it "gives an interaction and an occurrence", ->
        @builder.build """@found 'sth'"""
        iact = @diagram.find ".interaction:eq(0)"
        expect(iact.length).toBe 1
        expect(iact.find("> .occurrence").length).toBe 1

  describe "var", ->
    describe "found", ->
      beforeEach ->
        @diagram = @builder.build """
          @found 'var-found'
          @that = var_found
          """

      it "can be referred", ->
        expect(@builder.that).toBe @diagram.find(".object:eq(0)").data "_self"
      
    describe "message", ->
      beforeEach ->
        @diagram = @builder.build """
          @found 'sth', ->
            @message "var-message", "ano"
          @that = var_ano
          @it   = var_message
          """

      it "can be referred", ->
        expect(@builder.that).toBe @diagram.find(".object:eq(1)").data "_self"
        expect(@builder.it  ).toBe @diagram.find(".message:eq(0)").data "_self"
      
    describe "create", ->
      beforeEach ->
        @builder.build """
          @found 'sth', ->
            @create "var-create"
          @that = var_create
          """

      it "can be referred", ->
        expect(@builder.that).toBe @diagram.find(".object:eq(1)").data "_self"

    describe "ref", ->
      beforeEach ->
        @builder.build """
          @ref 'var-ref'
          @that = var_ref
          """

      it "can be referred", ->
        expect(@builder.that).toBe @diagram.find(".ref:eq(0)").data "_self"
