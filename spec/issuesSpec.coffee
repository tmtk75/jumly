SequenceDiagramBuilder = require "SequenceDiagramBuilder.coffee"
SequenceDiagramLayout  = require "SequenceDiagramLayout.coffee"
utils = require "./jasmine-utils.coffee"

describe "issues", ->
  
  div = utils.div this

  describe "#15", ->

    it "is empty for the .condition of fragment", ->
      code = '''
             @found "a", ->
               @loop "[until i > 100]", ->
                 @message "touch", "@create", ->
                 @fragment "critial section": ->
                   @message "select", "Context"
             '''
      diag = (new SequenceDiagramBuilder).build code

      conds = diag.find(".condition")
      expect(conds.length).toBe 2
      expect(conds.filter(":eq(0)").text()).toBe "[until i > 100]"
      expect(conds.filter(":eq(1)").text()).toBe ""
  
  describe "#12", ->
  
    describe "@create", ->
      beforeEach ->
        diag = (new SequenceDiagramBuilder).build '''
          @found "You", ->
            @create "Diagram", ->
              @reply "400"
          '''
        div.append diag
        (new SequenceDiagramLayout).layout diag

        occur = diag.find ".occurrence:eq(1)"
        @rmsg  = diag.find ".message.return"
        @bottom = occur.offset().top + occur.outerHeight() - 1
        @top    = @rmsg.offset().top

      it "top < bottom of occurrence", ->
        expect(@top).toBeLessThan @bottom

      it "bototm < bottom of occurrence", ->
        expect(@top + @rmsg.outerHeight() - 1).toBeGreaterThan @bottom
      
    describe "@message", ->
      beforeEach ->
        diag = (new SequenceDiagramBuilder).build '''
          @found "You", ->
            @message "get", "Diagram", ->
              @reply "200"
          '''
        div.append diag
        (new SequenceDiagramLayout).layout diag

        occur   = diag.find ".occurrence:eq(1)"
        @rmsg   = diag.find ".message.return"
        @bottom = occur.offset().top + occur.outerHeight() - 1
        @top    = @rmsg.offset().top

      it "top < bottom of occurrence", ->
        expect(@top).toBeLessThan @bottom

      it "bototm < bottom of occurrence", ->
        expect(@top + @rmsg.outerHeight() - 1).toBeGreaterThan @bottom

  describe "#6", ->
    describe "@found 'get'", ->
      it "can be built without exception", ->
        f = -> (new SequenceDiagramBuilder).build '''@found "get", ->'''
        expect(f).toThrow new Error("Reserved word 'get'")

  describe "issue#38", ->

    beforeEach ->
      @layout = new SequenceDiagramLayout
      @builder = new SequenceDiagramBuilder
      @diagram = @builder.diagram()

    describe "normal nested interaction", ->

      beforeEach ->
        @diagram = diag = @builder.build """
          @found "A", ->
            @message "1", "B",->
              @message "2", "A", ->
                @reply 3
            """
        div.append diag
        @layout.layout diag

        @interBA = diag.find ".interaction:eq(1)"
        @interBA.find("> .occurrence").css("background-color", "red")
        @interAB = diag.find ".interaction:eq(2)"
        @interAB.find("> .occurrence").css("background-color", "blue")

      it "contains reply message in nested interaction", ->
        #expect(@interBA.length).toBe 1
        #expect(@interAB.length).toBe 1
        expect(@interAB.find("> .message.return").length).toBe 1

    describe "self interaction", ->

      beforeEach ->
        @diagram = diag = @builder.build """
          @found "A", ->
            @message "1", "B",->
              @message "2", "B", ->
                @reply 3
            """
        div.append diag
        @layout.layout diag

        @interBB = diag.find ".interaction:eq(1)"
        @interBB.find("> .occurrence").css("background-color", "red")
        @interSelf = diag.find ".interaction:eq(2)"
        @interSelf.find("> .occurrence").css("background-color", "blue")

      it "contains reply message in nested interaction", ->
        #expect(@interBB.length  ).toBe 1
        #expect(@interSelf.length).toBe 1
        expect(@interBB.find("> .message.return").length  ).toBe 1
        expect(@interSelf.find("> .message.return").length).toBe 0

