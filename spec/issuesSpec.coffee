self = require: unless typeof require is "undefined" then require else JUMLY.require

self.require "node-jquery"
SequenceDiagramBuilder = self.require "SequenceDiagramBuilder"

describe "issues", ->

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
