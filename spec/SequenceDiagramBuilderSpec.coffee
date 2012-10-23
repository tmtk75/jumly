utils = require "./jasmine-utils"

describe "SequenceDiagramBuilder", ->
  SequenceDiagramBuilder = require "SequenceDiagramBuilder"

  beforeEach ->
    @builder = new SequenceDiagramBuilder
    @diagram = @builder.diagram()
    utils.matchers this

  describe "diagram", ->

    it "returns diagram", ->
      expect(@builder.diagram()).haveClass "diagram"
  
  describe "found", ->

    it "returns itself", ->
      expect(@builder.found "fiz").toBe @builder

    it "gives an object having .found", ->
      @builder.found "biz"
      obj = @diagram.find ".object"
      expect(obj.length).toBe 1
      expect(obj).haveClass "found"
      expect(obj.find(".name").text()).toBe "biz"
    
  describe "message", ->

    beforeEach ->
      @builder.found("foo")
              .message "call", "bar"
  
    it "returns itself", ->
      expect(@builder.found("foo").message "call").toBe @builder
    
    it "gives an interaction and an occurrence", ->
      iact = @diagram.find "> .interaction"
      expect(iact.length).toBe 1
      expect(iact.find("> .occurrence").length).toBe 1
      expect(iact.find("> .occurrence > .interaction").length).toBe 1
      expect(iact.find("> .occurrence > .interaction > .message").length).toBe 1

    describe "nest", ->

      it "returns back to previous occurrence", ->
        diag = @builder.build """
          @found "a", ->
            @message "1", "b", ->
              @message "1-1", "b-1", ->
            @message "2", "c", ->
              @message "1-1", "c-1", ->
          """
        root = diag.find "> .interaction"
        iacts = diag.find "> .interaction > .occurrence > .interaction"
        expect(root.length).toBe 1
        expect(iacts.length).toBe 2
        kid0 = iacts.find "> .occurrence:eq(0) > .interaction"
        kid1 = iacts.find "> .occurrence:eq(1) > .interaction"
        expect(kid0.length).toBe 1
        expect(kid1.length).toBe 1

  describe "create", ->

  describe "destroy", ->

  describe "reply", ->

  describe "ref", ->

    it "returns itself", ->
      a = @builder.ref "i'm ref"
      expect(a).toBe @builder

  describe "loop", ->

  describe "alt", ->

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

  describe "_curr_occurr", ->

    beforeEach ->
      @diagram = @builder.build """
        @found "sth"
        """
      @occurr = @diagram.find(".occurrence:eq(0)").data "_self"

    it "is changed by @found, @message", ->
      expect(@builder._curr_occurr()).toBe @occurr
      @builder.message "do", "foo"
      expect(@builder._curr_occurr()).toBe that = @occurr.find(".occurrence:eq(0)").data "_self"
      @builder.message "do", "bar"
      expect(@builder._curr_occurr()).toBe that.find(".occurrence:eq(0)").data "_self"

    it "is at the destination occurrence from the @message", ->
      diag = @builder.build """
        @found "a", ->
          @message "1", "b"
        """
      expect(@builder._curr_occurr()).toBe diag.find("""
        > .interaction:eq(0)
          > .occurrence:eq(0)
        """).data "_self"

    it "is at the destination occurrence from the @message", ->
      diag = @builder.build """
        @found "a", ->
          @message "1", "b"
          @message "2", "c"
        """
      expect(@builder._curr_occurr()).toBe diag.find("""
        > .interaction:eq(0)
          > .interaction:eq(1)
            > .occurrence:eq(0)
        """).data "_self"

    it "is changed by @create"

    it "is changed by @reactivate"

    it "is not changed by the others"
