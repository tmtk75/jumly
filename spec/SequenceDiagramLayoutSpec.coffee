core = require "core.coffee"
_u = require "jquery.ext.coffee"
utils = require "./jasmine-utils.coffee"
SequenceDiagramLayout = require "SequenceDiagramLayout.coffee"
SequenceDiagram = require "SequenceDiagram.coffee"
SequenceParticipant = require "SequenceParticipant.coffee"
SequenceDiagramBuilder = require "SequenceDiagramBuilder.coffee"

_bottom = (e)-> Math.round e.offset().top + e.outerHeight() - 1
_top = (e)-> Math.round e.offset().top
_right = (e)-> Math.round e.offset().left + e.outerWidth() - 1
_left = (e)-> Math.round e.offset().left

describe "SequenceDiagramLayout", ->

  div = utils.div this

  beforeEach ->
    @layout = new SequenceDiagramLayout
    @builder = new SequenceDiagramBuilder
    utils.matchers this

  it "has layout", ->
    expect(typeof @layout.layout).toBe "function"
  
  it "determines the size", ->
    diag = new SequenceDiagram
    diag.append obj = new SequenceParticipant "foobar"
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
      a = _u.min diag.find("*"), f = (e)-> $(e).offset().top
      b = _u.max diag.find("*"), g = (e)-> $(e).offset().top + $(e).outerHeight()
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
        t = @diagram.find(".participant, .occurrence, .ref") .map (i, e)-> $(e).outerHeight()
        fold = (list, init, func)->
          l = init
          for e in list
            l = func.apply null, [l, e]
          l
        reduce = (list, func)->
          return undefined if list.length is 0
          fold list[1..], list[0], func
        expect(@diagram.height()).toBeGreaterThan reduce t, (a, b)-> a + b
  
    describe "including .ref in .alt", ->
      beforeEach ->
        @diagram = diag = @builder.build """
          @found "it", ->
            @alt {
              "a": ->
                @message "do", "b"
                @ref "to them"
            }
          """
        div.append diag
        @layout.layout diag

      it "is longer than the sum of all ones", ->
        expect(_bottom @diagram).toBe (_u.max @diagram.find("*"), (e)-> _bottom $(e))

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
      @obj1 = @diagram.find(".participant:eq(0)").data "_self"
      @obj2 = @diagram.find(".participant:eq(1)").data "_self"
      @obj3 = @diagram.find(".participant:eq(2)").data "_self"

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
        a = diag.find(".participant:eq(0)").data "_self"
        b = diag.find(".participant:eq(1)").data "_self"
        expect(a.offset().top).toBe b.offset().top

    describe "left top", ->

      it "looks at same top for all", ->
        a = @diagram.find ".participant:eq(0)"
        b = @diagram.find ".participant:eq(1)"
        c = @diagram.find ".participant:eq(2)"
        expect(b.offset().top).toBe a.offset().top
        expect(c.offset().top).toBe b.offset().top
      
      it "is 0 for left of first .participant", ->
        expect(@obj1.position().left).toBe 0
      
      ## 40px is defined in .styl
      span = 40
      it "is a span #{span}px btw 1st and 2nd of .participant", ->
        x = @obj1.position().left + @obj1.preferred_width() + span
        expect(x).toBe @obj2.position().left

      it "is a span #{span}px btw 2nd and 3rd of .participant", ->
        x = @obj2.position().left + @obj3.preferred_width() + span
        expect(x).toBe @obj3.position().left

  describe "lifeline", ->

    beforeEach ->
      @diagram = @builder.build """
        @found "lifeline"
        """
      div.append @diagram
      @layout.layout @diagram
      @obj = @diagram.find(".participant:eq(0)").data "_self"
      @lifeline = @diagram.find(".lifeline:eq(0)").data "_self"

    describe "left", ->

      it "is at the center of object", ->
        c = @obj.offset().left + @obj.preferred_width()/2 + 1
        expect(@lifeline.find(".line").offset().left).toBe c

    describe "top", ->
      
      it "is btw .participant and its .occurrence", ->
        obj = @diagram.find ".participant:eq(0)"
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
        a = _u.max lines, g
        b = _u.max occurs, g
        expect(a).toBeGreaterThan b

      describe "for two top interactions", ->
        it "is longer", ->
          diag = (new SequenceDiagramBuilder).build """
            @found 'a', ->
              @message '1', 'b', ->
            @found 'b', ->
              @message '2', 'c', ->
            """
          div.append diag
          @layout.layout diag

          expect(_bottom diag.find(".lifeline:eq(0)")).toBeGreaterThan _bottom diag.find("> .interaction:eq(1)")

  describe "occurrence", ->

    beforeEach ->
      @diagram = @builder.build """
        @found "occurrence"
        """
      div.append @diagram
      @layout.layout @diagram
      @obj = @diagram.find(".participant:eq(0)").data "_self"
      @occurr = @diagram.find(".occurrence:eq(0)").data "_self"

    describe "left", ->

      it "is at left of the center of object", ->
        c = @obj.offset().left + @obj.preferred_width()/2 + 1
        expect(@occurr.offset().left).toBeLessThan c

  describe "found", ->

    it "looks centering" #, ->
      #div.append @builder.build "@found 'foundee'"
      #@layout.layout diag = @builder.diagram()

    describe "object", ->
      describe "initial left", ->
        it "is auto for plain div", ->
          a = $("<div>")
          div.append a
          expect(a.css "left").toBe "auto"
          
        it "is auto for div.participant", ->
          a = $("<div>").addClass "object"
          div.append a
          expect(a.css "left").toBe "auto"
          
        it "is auto for SequenceParticipant", ->
          a = new SequenceParticipant
          div.append a
          expect(a.css "left").toBe "auto"
        
        it "is auto for relative div in relative div", ->
          a = $("<div>").css position:"relative"
          diag = $("<div>").css position:"relative"
          diag.append a
          div.append diag
          expect(a.css "left").toBe "auto"

        it "is auto for SequenceParticipant in SequenceDiagram", ->
          a = new SequenceParticipant
          diag = new SequenceDiagram
          diag.append a
          div.append diag
          expect(a.css "left").toBe "auto"

        it "is auto for .participant created by builder", ->
          b = new SequenceDiagramBuilder
          b.found "sth"
          div.append b.diagram()
          expect(b.diagram(".participant:eq(0)").css "left").toBe "auto"

      describe "left", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "sth"
            @left = sth.css "left"
            """
          div.append @diagram

        it "is empty for the left from builder context", ->
          expect(@builder.left).toBe ""

        it "is auto for the left after appended to body", ->
          expect(@diagram.find(".participant:eq(0)").css "left").toBe "auto"


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
        @obj = @diagram.find(".participant:eq(0)").data "_self"
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
          @found "mouse", ->
            @loop ->
              @message "rotate", "wheel"
          """
        div.append @diagram
        @layout.layout @diagram
        @obj = @diagram.find(".participant:eq(0)").data "_self"
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

  describe "fragment", ->
    describe "header", ->
      describe "name", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "something", ->
              @fragment transaction:->
                @note "start a trax"
          """
          div.append @diagram
          @layout.layout @diagram

        it "doesn't overlap with note", ->
          a = _bottom @diagram.find ".fragment .header .name:eq(0)"
          b = _top @diagram.find ".note"
          expect(a).toBeLessThan b

  describe "ref", ->
    describe "one object and it's second element", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "sth"
          @ref "other"
          """
        div.append @diagram
        @layout.layout @diagram
        @obj = @diagram.find(".participant:eq(0)").data "_self"
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

    describe "in .alt", ->
      describe "two .participants", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "sth", ->
              @alt {
                "[abc]": ->
                  @message "to", "futher"
                  @ref "efg"
              }
            """
          div.append @diagram
          @layout.layout @diagram

        it "fit to .alt", ->
          alt = @diagram.find ".alt"
          ref = @diagram.find ".ref"
          expect(_left ref).toBeGreaterThan _left alt
          expect(_right ref).toBeLessThan _right alt

      describe "one object", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "sth", ->
              @alt {
                "[abc]": ->
                  @ref "efg"
              }
            """
          div.append @diagram
          @layout.layout @diagram

        xit "fit to .alt", ->
          ## NOTE: The spec is undefined
          alt = @diagram.find ".alt"
          ref = @diagram.find ".ref"
          expect(_left ref).toBeGreaterThan _left alt
          expect(_right ref).toBeLessThan _right alt

    describe "left", ->
      describe "next of .alt", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "You", ->
              @alt {
                "[found]": ->
                  @loop ->
                    @message "request", "HTTP Server"
                "[missing]": ->
                  @message "new", "HTTP Session"
              }
              @ref "respond resource"
            """
          div.append @diagram
          @layout.layout @diagram
          @ref = @diagram.respond_resource

        it "is at right to the left of 1st .occurrence", ->
          occur = @diagram.find ".occurrence:eq(0)"
          expect(_left occur).toBeLessThan _left @ref

        it "is at left to the right of 1st .occurrence", ->
          occur = @diagram.find ".occurrence:eq(0)"
          expect(_left @ref).toBeLessThan _right occur

        it "is at left to the center of 2rd .participant", ->
          obj = @diagram.find ".participant:eq(1)"
          expect(_right @ref).toBeLessThan (_left obj) + obj.outerWidth()/2

    describe "width", ->
      describe "initialy", ->
        beforeEach ->
          @diagram = @builder.build """
                       @ref 'im ref'
                       """
        it "is 0px", ->
          expect(@diagram.find(".ref").css "width").toBe "0px"
        
        it "has a value after layout", ->
          a = @diagram
          div.append a
          @layout.layout a
          expect(a.find(".ref").css "width").not.toBe "0px"

      describe "auto or manual", ->
        it "is given if it's used", ->
          a = (new SequenceDiagramBuilder).build """
                    @ref 'to me'
                    """
          b = (new SequenceDiagramBuilder).build """
                    @ref 'to you'
                    to_you.css width:80, "min-width":0
                    """
          div.append a
          div.append b
          @layout.layout a
          @layout.layout b

          ## depends on other nodes metrics
          expect(a.to_me.width()).toBeGreaterThan 0 #parseInt a.to_me.css("min-width")
          expect(a.to_me.width()).toBeLessThan a.outerWidth()

          ## specified by css
          expect(b.to_you.width()).toBe 80

        it "fits to lifelines", ->
          diag = @builder.build """
                @found "You", ->
                  @message "pass", "Me", ->
                    @message "pass", "Him"
                  @ref "respond resource"
                  """
          div.append diag
          @layout.layout diag

          ref   = diag.find ".ref"
          occur = diag.find ".occurrence:eq(1)"
          obj   = diag.find ".participant:eq(1)"
          occur.css "background-color":"#ff8080"
          obj.css "color":"#ff8080"
          expect(_left obj).toBeLessThan _right ref
          expect(_right ref).toBeLessThan _right obj
          expect(_left occur).toBeLessThan _right ref
          expect(_right ref).toBeLessThan _right occur

    describe "index", ->
      it "keeps the position", ->
        a = (new SequenceDiagramBuilder).build """
                  @found "g", -> 
                    @ref 'to me'
                  """
        b = (new SequenceDiagramBuilder).build """
                  @found "g", -> 
                    @message "a", "b"
                    @ref 'to you'
                    @message "c", "d"
                  """
        c = (new SequenceDiagramBuilder).build """
                  @found "g", -> 
                    @message "a", "b"
                    @message "c", "d"
                    @ref 'to him'
                    @message "e", "f"
                  """
        div.append a
        div.append b
        div.append c
        @layout.layout a
        @layout.layout b
        @layout.layout c

        expect(a.find(".ref").index()).toBe 0
        expect(b.find(".ref").index()).toBe 1
        expect(c.find(".ref").index()).toBe 2

  describe "reply", ->

    describe "name", ->
      beforeEach ->
        @diagram = d = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @reply "hello"
          """
        div.append d
        @layout.layout d

      it "is below of .arrow", ->
        a = @diagram.find(".arrow")
        b = @diagram.find(".return .name")
        expect(a.offset().top).toBeLessThan b.offset().top

    describe "looks", ->
      describe "https://github.com/tmtk75/jumly/issues/4", ->
        beforeEach ->
          @diagram = @builder.build """
            @found "App", ->
              @message "Register", "Engine", ->
                @reply "OK"
              @message "Do It", "Engine", ->
                @reply "NG"
            """
          div.append @diagram
          @layout.layout @diagram

        it "doesn't overlap", ->
          a = @diagram.find ".return:eq(0)"
          b = @diagram.find ".message:eq(2)"
          expect(_bottom a).toBeLessThan _top b

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
      @obj = diag.find ".participant.created-by"
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
          act = @diagram.find ".participant:eq(0)"
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
            obj0 = diag.find ".participant:eq(0)"
            obj1 = diag.find ".participant:eq(1)"
            obj2 = diag.find ".participant:eq(2)"
            expect(_u.outerBottom(obj0)).toBeLessThan obj1.offset().top
            expect(_u.outerBottom(obj1)).toBeLessThan obj2.offset().top

    describe "lifeline", ->
      describe "top", ->

        it "is at the bottom of its .participant", ->
          a = @diagram.find(".lifeline:eq(0)").data "_self"
          b = @diagram.find(".lifeline:eq(1)").data "_self"
          expect(_top a).toBeGreaterThan _bottom a._object
          expect(_top b).toBeGreaterThan _bottom b._object

      describe "bottom", ->

        it "is at the same", ->
          a = @diagram.find ".lifeline:eq(0)"
          b = @diagram.find ".lifeline:eq(1)"
          expect(_bottom a).toBe _bottom b

  describe "note", ->
    describe "prev message", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "sth", ->
            @note "Here is a note"
            @message "a", "b"
          """
        div.append @diagram
        @layout.layout @diagram

      it "has .note", ->
        expect(@diagram.find(".note").outerWidth()).toBeGreaterThan 0
      
      it "has a text", ->
        expect(@diagram.find(".note").text()).toBe "Here is a note"
  
    describe "next message", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "A", ->
            @note "a note"
            @message "b", "B", ->
            @message "d", "C", ->
              @message "e", "B", ->
                @note "I'm a note"
          """
        div.append @diagram
        @layout.layout @diagram

      describe "the first one", ->
        it "has 9px top margin", ->
          note = @diagram.find ".note:eq(0)"
          expect(note.css "margin-top").toBe "-9px"

      it "is below of the message", ->
        msg = @diagram.find ".message:eq(2)"
        note = @diagram.find ".note:eq(1)"
        y = @diagram.offset().top
        a = msg.offset().top + msg.outerHeight() - 1 - y
        b = note.offset().top - y
        ## Below is the best expectation, but
        #expect(a - b).toBe 0
        expect(a - b).toBeLessThan 1.0

  describe "marker", ->

    describe "occurrence", ->
      beforeEach ->
        @diagram = @builder.build """
          @found "A", ->
            @message "b", "B"
            @message "c", "C"
          """
        div.append @diagram
        @layout.layout @diagram

      it "has .leftmost for the 1st occurrence", ->
        expect(@diagram.find(".occurrence:eq(0)").hasClass "leftmost").toBeTruthy()

      it "has no .leftmost and .righmostt for the 2nd occurrence", ->
        expect(@diagram.find(".occurrence:eq(1)").hasClass "leftmost").toBeFalsy()
        expect(@diagram.find(".occurrence:eq(1)").hasClass "rightmost").toBeFalsy()

      it "has .rightmost for the 3rd occurrence", ->
        expect(@diagram.find(".occurrence:eq(2)").hasClass "rightmost").toBeTruthy()


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
            $(".participant .name, .message .name").hover f, g
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
