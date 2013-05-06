self = require: unless typeof require is "undefined" then require else JUMLY.require

self.require "node-jquery"
SequenceDiagramBuilder = self.require "SequenceDiagramBuilder"
SequenceDiagramLayout  = self.require "SequenceDiagramLayout"
utils = self.require "./jasmine-utils"

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
  
  utils.unless_node -> describe "#12", ->
  
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
