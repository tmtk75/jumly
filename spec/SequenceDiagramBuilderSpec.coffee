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

  describe "directive", ->
    describe "found", ->

      it "gives an object having .found", ->
        @builder.found "biz"
        obj = @diagram.find ".participant"
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

      describe "empty string given", ->
        it "throws an error", ->
          expect(-> @builder.build '@found ""').toThrow()
      
    describe "message", ->

      describe "to itself", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "a", ->
              @message "1", "a", ->
            """

        it "has .self", ->
          expect(@diagram.find(".self")).haveClass "interaction"

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
          it "creates an .participant", ->
            @builder.diagram().find("*").remove()
            diag = @builder.build """
              @found "HTTP Server", ->
                @create "HTTP Session"
                @message "save state", "HTTP Session"
              """
            expect(diag.find(".participant").length).toBe 2

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
    
      describe "name", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "a", ->
              @message "1", "b", ->
                @reply "hello"
            """

        it "has .name 'hello'", ->
          expect(@diagram.find(".return .name").text()).toBe "hello"

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
      
      it "equals to .interaction", ->
        diag = @builder.build """
          @found "open", ->
          @ref "see"
          """
        expect(diag.see).toBe diag.find(".interaction + .ref:eq(0)").data "_self"

      it "can be in .interaction", ->
        diag = @builder.build """
          @found "open", ->
            @ref "see"
          """
        expect(diag.see).toBe diag.find(".occurrence > .ref:eq(0)").data "_self"

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
    
    describe "note", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "sth", ->
            @note "Here is a note", css:margin:4
          """

      it "has .note", ->
        expect(@diagram.find(".note").length).toBe 1
      
      it "has margin:4", ->
        expect(@diagram.find(".note").css "margin").toBe "4px"
    
  describe "build", ->

    it "should return node has class .diagram", ->
      node = @builder.build ""
      expect(node).haveClass "diagram"
    
    it "should return what equal to @diagram()", ->
      node = @builder.build ""
      expect(node).toBe @builder.diagram()

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
        expect(@builder.that).toBe @diagram.find(".participant:eq(0)").data "_self"
        expect(@diagram.var_found).toBe @builder.that
      
    describe "message", ->
      beforeEach ->
        @diagram = @builder.build """
          @found 'sth', ->
            @message "var-msg", "var ano"
          @that = var_ano
          """

      it "can be referred", ->
        expect(@builder.that).toBe @diagram.find(".participant:eq(1)").data "_self"
        expect(@diagram.var_ano).toBe @builder.that
      
    describe "create", ->
      beforeEach ->
        @diagram = @builder.build """
          @found 'sth', ->
            @create "var-create"
          @that = var_create
          """

      it "can be referred", ->
        expect(@builder.that).toBe @diagram.find(".participant:eq(1)").data "_self"
        expect(@diagram.var_create).toBe @builder.that

    describe "ref", ->
      beforeEach ->
        @diagram = @builder.build """
          @ref 'var ref'
          @that = var_ref
          """

      it "can be referred", ->
        expect(@builder.that).toBe @diagram.find(".ref:eq(0)").data "_self"
        expect(@diagram.var_ref).toBe @builder.that

      describe "in .alt", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "Browser", ->
              @alt {
                "[200]": -> @message "GET href resources", "HTTP Server"
                "[301]": -> @ref "GET the moved page"
                "[404]": -> @ref "show NOT FOUND"
              }
            @that = get_the_moved_page
            """

        it "can be referred by id", ->
          expect(@diagram.get_the_moved_page).toBe @builder.that
  
  describe "css", ->
    beforeEach ->
      @diagram = @builder.build """
        @ref 'var-ref'
        @css color:"blue", "font-weight":"bold"
        """

    it "applies styles to diagram", ->
      _ = utils.ua
      expect(@diagram.css "color").toBe _ webkit:"blue", gecko:'rgb(0, 0, 255)'
      expect(@diagram.css "font-weight").toBe _ webkit:"bold", gecko:'700'
 
  describe "find", ->
    beforeEach ->
      @diagram = @builder.build """
        @found "hi"
        @that = @find(".participant:eq(0)").data "_self"
        """

    it "equals to $.find", ->
      expect(@diagram.hi).toBe @builder.that
