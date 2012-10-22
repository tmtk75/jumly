require "core"
require "jquery.ext"
utils = require "./jasmine-utils"
SequenceDiagramLayout = require "SequenceDiagramLayout"
SequenceDiagram = require "SequenceDiagram"
SequenceObject = require "SequenceObject"
SequenceDiagramBuilder = require "SequenceDiagramBuilder"

describe "SequenceDiagramLayout", ->

  div = utils.div this

  beforeEach ->
    @layout = new SequenceDiagramLayout
    @builder = new SequenceDiagramBuilder

  it "has layout", ->
    expect(typeof @layout.layout).toBe "function"
  
  utils.unless_node ->
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
      a = diag.find("*").min f = (e)-> $(e).offset().top
      b = diag.find("*").max g = (e)-> $(e).offset().top + $(e).outerHeight()
      expect(diag.height()).toBe Math.round(b - a)

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

    afterEach ->
      #[@diagram.hide()

    describe "left top", ->

      it "looks at same top for all", ->
        a = @diagram.find ".object:eq(0)"
        b = @diagram.find ".object:eq(1)"
        c = @diagram.find ".object:eq(2)"
        expect(b.offset().top).toBe a.offset().top
        expect(c.offset().top).toBe b.offset().top
      
      it "is 0 for left of first .object", ->
        expect(@obj1.position().left).toBe 0
      
      ## 60px is defined in .styl
      it "is a span 60px btw 1st and 2nd of .object", ->
        x = @obj1.position().left + @obj1.preferred_width() + 60
        expect(x).toBe @obj2.position().left

      it "is a span 60px btw 2nd and 3rd of .object", ->
        x = @obj2.position().left + @obj3.preferred_width() + 60
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
    utils.unless_node ->

      it "looks centering" #, ->
        #div.append @builder.build "@found 'foundee'"
        #@layout.layout diag = @builder.diagram()

  describe "message", ->

    describe "self-message", ->

      utils.unless_node -> it "works without args after 2nd", ->
        diag = @builder.build """
          @found "a", ->
            @message "msg to myself"
          """
        div.append diag
        @layout.layout diag

    utils.unless_node -> it "works for an one interaction", ->
      diag = @builder.build """
        @found "That", ->
          @message "finds", "it"
        """
      div.append diag
      @layout.layout diag

  describe "showcase", ->
  
    utils.unless_node -> it "has full functions", ->
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

    utils.unless_node -> it "has @loop, @alt and @ref", ->
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
