require "core"
require "jquery.ext"
utils = require "./jasmine-utils"
SequenceDiagramLayout = require "SequenceDiagramLayout"
SequenceDiagram = require "SequenceDiagram"
SequenceObject = require "SequenceObject"
SequenceDiagramBuilder = require "SequenceDiagramBuilder"

_bottom = (e)-> Math.round e.offset().top + e.outerHeight() - 1
_top = (e)-> Math.round e.offset().top
_right = (e)-> Math.round e.offset().left + e.outerWidth() - 1

utils.unless_node -> describe "SequenceDiagramLayout", ->

  div = utils.div this

  beforeEach ->
    @layout = new SequenceDiagramLayout
    @builder = new SequenceDiagramBuilder
    utils.matchers this

  it "has layout", ->
    expect(typeof @layout.layout).toBe "function"
  
  it "determines the size", ->
    diag = new SequenceDiagram
    diag.append obj = new SequenceObject "foobar"
    div.append diag
    @layout.layout diag
    expect(diag.width()).toBeGreaterThan 0
    expect(diag.height()).toBeGreaterThan 0

  describe "height", ->

    it "is 0 for empty", ->
      @layout.layout diag = new SequenceDiagram
      expect(diag.height()).toBe 0

    it "depends on min top and max bottom", ->
      diag = @builder.build """
        @found "height-a"
        """
      div.append diag
      @layout.layout diag
      diag.css "border":"1px solid #008000"
      a = diag.find("*").min f = (e)-> $(e).offset().top
      b = diag.find("*").max g = (e)-> $(e).offset().top + $(e).outerHeight()
      expect(diag.height()).toBe Math.round(b - a)

    describe "including .ref", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "sth"
          @ref "to"
          """
        div.append @diagram
        @layout.layout @diagram

      it "is longer than the sum of all ones", ->
        t = @diagram.find(".object, .occurrence, .ref") .map (i, e)-> $(e).outerHeight()
        expect(@diagram.height()).toBeGreaterThan $.reduce t, (a, b)-> a + b
  
  describe "width", ->
    beforeEach ->
      @diagram = diag = @builder.build """
        @found "a", -> @message "b", "c"
        """
      div.append diag
      @layout.layout diag

    it "is 0px for css min-width", ->
      expect(@diagram.css "min-width").toBe "0px"

    it "is none for css max-width", ->
      expect(@diagram.css "max-width").toBe "none"

  describe "object", ->
    beforeEach ->
      @diagram = @builder.build """
        @found "a", ->
          @message "1", "b", ->
            @message "2", "c"
        """
      div.append @diagram
      @layout.layout @diagram
      @obj1 = @diagram.find(".object:eq(0)").data "_self"
      @obj2 = @diagram.find(".object:eq(1)").data "_self"
      @obj3 = @diagram.find(".object:eq(2)").data "_self"

    describe "width", ->

      it "is 100px", ->
        expect(@obj1.outerWidth()).toBe 100

    describe "height", ->

      it "is 35px", ->
        expect(@obj1.outerHeight()).toBe 35

    describe "top", ->

      it "is aligned", ->
        expect(@obj1.offset().top).toBe @obj2.offset().top
        expect(@obj2.offset().top).toBe @obj3.offset().top
      
      it "is aligned for two objects", ->
        @diagram.remove()
        builder = new SequenceDiagramBuilder()
        diag = builder.build """
            @found "You", ->
              @message "use", "JUMLY"
          """
        div.append diag
        @layout.layout diag
        a = diag.find(".object:eq(0)").data "_self"
        b = diag.find(".object:eq(1)").data "_self"
        expect(a.offset().top).toBe b.offset().top

    describe "left top", ->

      it "looks at same top for all", ->
        a = @diagram.find ".object:eq(0)"
        b = @diagram.find ".object:eq(1)"
        c = @diagram.find ".object:eq(2)"
        expect(b.offset().top).toBe a.offset().top
        expect(c.offset().top).toBe b.offset().top
      
      it "is 0 for left of first .object", ->
        expect(@obj1.position().left).toBe 0
      
      ## 40px is defined in .styl
      span = 40
      it "is a span #{span}px btw 1st and 2nd of .object", ->
        x = @obj1.position().left + @obj1.preferred_width() + span
        expect(x).toBe @obj2.position().left

      it "is a span #{span}px btw 2nd and 3rd of .object", ->
        x = @obj2.position().left + @obj3.preferred_width() + span
        expect(x).toBe @obj3.position().left

  describe "lifeline", ->

    beforeEach ->
      @diagram = @builder.build """
        @found "lifeline"
        """
      div.append @diagram
      @layout.layout @diagram
      @obj = @diagram.find(".object:eq(0)").data "_self"
      @lifeline = @diagram.find(".lifeline:eq(0)").data "_self"

    describe "left", ->

      it "is at the center of object", ->
        c = @obj.offset().left + @obj.preferred_width()/2 + 1
        expect(@lifeline.find(".line").offset().left).toBe c

    describe "top", ->
      
      it "is btw .object and its .occurrence", ->
        obj = @diagram.find ".object:eq(0)"
        line = @diagram.find ".lifeline:eq(0) .line"
        occurr = @diagram.find ".occurrence:eq(0)"
        y0 = _bottom obj
        y1 = line.offset().top
        y2 = occurr.offset().top
        expect(y1).toBeGreaterThan y0
        expect(y2).toBeGreaterThan y1

    describe "bottom", ->

      beforeEach ->
        @diagram.remove()
        @diagram = diag = (new SequenceDiagramBuilder).build """
          @found 'a', ->
            @message '1', 'b', ->
              @message '2', 'c'
          """
        div.append diag
        @layout.layout diag
      
      it "is at mostbottom than the others", ->
        lines = @diagram.find ".lifeline"
        occurs = @diagram.find ".occurrence"
        g = (e)-> _bottom $(e)
        a = lines.max g
        b = occurs.max g
        expect(a).toBeGreaterThan b

  describe "occurrence", ->

    beforeEach ->
      @diagram = @builder.build """
        @found "occurrence"
        """
      div.append @diagram
      @layout.layout @diagram
      @obj = @diagram.find(".object:eq(0)").data "_self"
      @occurr = @diagram.find(".occurrence:eq(0)").data "_self"

    describe "left", ->

      it "is at left of the center of object", ->
        c = @obj.offset().left + @obj.preferred_width()/2 + 1
        expect(@occurr.offset().left).toBeLessThan c

  describe "found", ->

    it "looks centering" #, ->
      #div.append @builder.build "@found 'foundee'"
      #@layout.layout diag = @builder.diagram()

  describe "message", ->

    describe "self-message", ->

      it "works without args after 2nd", ->
        diag = @builder.build """
          @found "a", ->
            @message "msg to myself"
          """
        div.append diag
        @layout.layout diag

    it "works for an one interaction", ->
      diag = @builder.build """
        @found "That", ->
          @message "finds", "it"
        """
      div.append diag
      @layout.layout diag

  describe "loop", ->

    describe "condition is given", ->
      beforeEach ->
        utils.matchers this
        @diagram = @builder.build """
          @found "mouse", ->
            @loop "i < 10", ->
              @message "rotate", "wheel"
          """
        div.append @diagram
        @layout.layout @diagram
        @obj = @diagram.find(".object:eq(0)").data "_self"
        @loop = @diagram.find(".loop:eq(0)").data "_self"

      it "has .loop", ->
        expect(@loop).haveClass "loop"

      it "has 'Loop' .name", ->
        expect(@loop.find(".header .name").text()).toBe "Loop"

      it "has 'i < 10' .condition", ->
        expect(@loop.find(".condition").text()).toBe "i < 10"

    describe "function is given", ->
      beforeEach ->
        utils.matchers this
        @diagram = @builder.build """
          @found "mouse"
          @loop ->
            @message "rotate", "wheel"
          """
        div.append @diagram
        @layout.layout @diagram
        @obj = @diagram.find(".object:eq(0)").data "_self"
        @loop = @diagram.find(".loop:eq(0)").data "_self"

      it "has .loop", ->
        expect(@loop).haveClass "loop"

      it "has 'Loop' .name", ->
        expect(@loop.find(".header .name").text()).toBe "Loop"

  describe "alt", ->

    beforeEach ->
      utils.matchers this
      @diagram = @builder.build """
        @found "open", ->
          @alt {
            "[found]": -> @message "write", "File"
            "[missing]": -> @message "close", "File"
          }
        """
      div.append @diagram
      @layout.layout @diagram
      @alt = @diagram.find(".alt:eq(0)").data "_self"

    it "has two .messages which are same length", ->
      m0 = @alt.find ".message:eq(0)"
      m1 = @alt.find ".message:eq(1)"
      expect(m0.outerWidth()).toBe m1.outerWidth()

  describe "ref", ->
    describe "one object and it's second element", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "sth"
          @ref "other"
          """
        div.append @diagram
        @layout.layout @diagram
        @obj = @diagram.find(".object:eq(0)").data "_self"
        @ref = @diagram.find(".ref:eq(0)").data "_self"

      it "can be second element", ->
        y0 = _bottom @obj
        y1 = _top @ref
        expect(y0).toBeLessThan y1
    
      it "is at left to the left of object", ->
        expect(@ref.offset().left).toBeLessThan @obj.offset().left
      
      it "is at right to the right of object", ->
        expect(_right @ref).toBeGreaterThan _right @obj

    describe "first element", ->
      it "can be first element", ->
        diag = new SequenceDiagramBuilder().build """
          @ref 'to another'
          """
        div.append diag
        @layout.layout diag
        ref = diag.find ".ref"
        expect(ref.outerWidth()).toBeGreaterThan 88*1.41

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
        div.append diag
        @layout.layout diag
        @ret1 = diag.find ".return:eq(1)"
        @ret2 = diag.find ".return:eq(0)"

      it "is as offset.left as the sibling", ->
        m1 = @ret1.parent().find(".message:eq(0)")
        expect(m1.text()).toBe "1"
        expect(@ret1.offset().left).toBe m1.offset().left

        m2 = @ret2.parent().find(".message:eq(0)")
        expect(m2.text()).toBe "2"
        expect(@ret2.offset().left).toBe m2.offset().left

    describe "returning back to the ancestor", ->
      
      beforeEach ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "2", "c", ->
                @reply "2'", "a"
              @reply "1'", "a"
          """
        div.append diag
        @layout.layout diag
        @ret1 = diag.find ".return:eq(1)"
        @ret2 = diag.find ".return:eq(0)"

      it "is as offset.left as the sibling", ->
        m1 = @ret1.parent().find(".message:eq(0)")
        expect(m1.text()).toBe "1"
        expect(@ret1.offset().left).toBe m1.offset().left
        expect(@ret2.offset().left).toBe m1.offset().left

    describe "returning back from one self-called occurrence", ->

      beforeEach ->
        @diagram = diag = @builder.build """
          @found "Me", ->
            @message "mail", "Him", ->
              @message "read", ->
                @reply "reply", "Me"
          """
        div.append diag
        @layout.layout diag
        @ret = diag.find ".return:eq(0)"
        @occurr = diag.find(".return:eq(0)").parents(".occurrence:eq(0)")

      it "is as left as its source occurrence", ->
        expect(@ret.offset().left).not.toBeGreaterThan @occurr.offset().left

    describe "returning back from multiple self-called occurrences", ->

      beforeEach ->
        @diagram = diag = @builder.build """
          @found "Me", ->
            @message "mail", "Him", ->
              @message "read", ->
                @message "again", ->
                  @message "and again", ->
                    @reply "reply", "Me"
            """
        div.append diag
        @layout.layout diag
        @ret = diag.find ".return:eq(0)"
        @occurr = diag.find(".return:eq(0)").parents(".occurrence:eq(0)")

      it "is as left as its source occurrence", ->
        expect(@ret.offset().left).not.toBeGreaterThan @occurr.offset().left

    describe "semantic errors", ->

      describe "no target for reply", ->

        it "throws an Error for no target", ->
          layout = new SequenceDiagramLayout
          builder = new SequenceDiagramBuilder
          f = ->
            diag = builder.build """
              @found "User", ->
                @message "search", "Browser", ->
                  @reply "", "Browser"
              """
            div.append diag
            layout.layout diag
          expect(f).toThrow()
          try
            f()
            expect("").toBe "never come"
          catch err
            expect(err.message).toBe "SemanticError: it wasn't able to reply back to 'Browser' which is missing"

  describe "create", ->

    beforeEach ->
      @diagram = diag = @builder.build """
        @found 'a', ->
          @create 'b'
        """
      div.append diag
      @layout.layout diag
      @obj = diag.find ".object.created-by"
      @msg = diag.find(".create.message").data "_self"

    describe "message", ->
      describe "right", ->

        it "is at left from the left of actee object", ->
          expect(@msg.offset().left + @msg.outerWidth()).toBeLessThan @obj.offset().left

        it "is same for the both of left", ->
          occur = @diagram.find ".occurrence:eq(0)"
          expect(@msg.offset().left).toBe occur.offset().left

      describe "asynchronous", ->

        it "has .asynchronous", ->
          @diagram.remove()
          diag = (new SequenceDiagramBuilder()).build """
            @found 'a', ->
              @message asynchronous:"up", "b"
            """
          div.append diag
          @layout.layout diag
          expect(diag.find(".asynchronous").length).toBe 1

    describe "object", ->
      describe "top", ->

        it "is at bottom of the bottom of actor object", ->
          act = @diagram.find ".object:eq(0)"
          expect(@obj.offset().top).toBeGreaterThan act.offset().top + act.outerHeight()

        describe "twice", ->
          it "is at bottom than previous ones", ->
            @diagram.remove()
            diag = (new SequenceDiagramBuilder()).build """
              @found 'a', ->
                @create 'b', ->
                  @create 'c', ->
              """
            div.append diag
            @layout.layout diag
            obj0 = diag.find ".object:eq(0)"
            obj1 = diag.find ".object:eq(1)"
            obj2 = diag.find ".object:eq(2)"
            expect(obj0.outerBottom()).toBeLessThan obj1.offset().top
            expect(obj1.outerBottom()).toBeLessThan obj2.offset().top

    describe "lifeline", ->
      describe "top", ->

        it "is at the bottom of its .object", ->
          a = @diagram.find(".lifeline:eq(0)").data "_self"
          b = @diagram.find(".lifeline:eq(1)").data "_self"
          expect(_top a).toBeGreaterThan _bottom a._object
          expect(_top b).toBeGreaterThan _bottom b._object

      describe "bottom", ->

        it "is at the same", ->
          a = @diagram.find ".lifeline:eq(0)"
          b = @diagram.find ".lifeline:eq(1)"
          expect(_bottom a).toBe _bottom b
          

  describe "showcase", ->
  
    it "has full functions", ->
      diag = @builder.build """
        @found "User", ->
          @message "search", "Browser", ->
            @message "http request", "HTTP Server", ->
              @create "HTTP Session"
              @message "save state", "HTTP Session"
              @message "do something"
              @message "query", "Database", ->
              @reply "", "Browser"
            @loop @message "request resources", "HTTP Server", ->
              @alt {
                "[found]": -> @message "update", "Database"
                "[missing]": -> @message "scratch", "HTTP Session"
              }
            @ref "Rendering page"
            @reactivate "disconnect", "HTTP Server", ->
              @destroy "HTTP Session"
          
          ###
          @before (e, d) ->
            d.user.iconify "actor"
            d.browser.iconify "view"
            d["http_session"].iconify "controller"
            d["http_server"].iconify "controller"
            d.database.iconify("entity").css("margin-left":-80)
            d["http_session"].lost()
          
          @after (e, diag)->
            f = (e)-> $(e.currentTarget).addClass "focused-hovered"
            g = (e)-> $(e.currentTarget).removeClass "focused-hovered"
            $(".object .name, .message .name").hover f, g
          ###
        """
      div.append diag
      @layout.layout diag

    it "has @loop, @alt and @ref", ->
      diag = @builder.build """
        @found "You", ->
          @message "open", "Front Cover"
          @loop ->
            @alt
              "[page > 0]": -> @message "flip", "Page"
              "[page = 0]": -> @message "stop reading"
            @message "read", "Page"
          @message "close", "Front Cover"
          @ref "Tidy up book at shelf"
        """
      div.append diag
      @layout.layout diag

    it "has @reply", ->
      diag = @builder.build """
        @found "You", ->
          @message "contact", "Me", ->
            @loop @message "mail", "Him", ->
              @message "read", ->
                @reply "reply", "Me"
            @reply "", "You"
        """
      div.append diag
      @layout.layout diag
