self = require: unless typeof require is "undefined" then require else JUMLY.require

self.require "node-jquery"
core = self.require "core"
self.require "api"

describe "JUMLY", ->

  describe "eval", ->

    describe "a jQuery node is given", ->
      it "makes a new diagram and ", ->

    describe "a string is given", ->

      describe "with `into`", ->
        it "makes a new diagram and put it"

      describe "with a funciton `placer`", ->
        it "makes a new diagram and put it"


  describe "scan", ->

    describe "a jQuery nodeset is given", ->
      it "makes a new diagram after each node which has data-jumly attr", ->
        nodes = $ """
                  <div>
                    <div data-jumly="">@found "that"</div>
                  </div>
                  """
        JUMLY.scan nodes
        expect(nodes.find("> .diagram").length).toBe 1

    describe "with opiton", ->

      describe "which has an funciton placer", ->
        nodes = $ """
                  <div>
                    <div data-jumly="">@found "dog"</div>
                  </div>
                  """
        JUMLY.scan nodes, placer:(d, $e)-> nodes.html d
        expect(nodes.find("> .diagram").length).toBe 1
        expect(nodes.find("> *").length).toBe 1

      describe "which has an funciton finder", ->
        nodes = $ """
                  <div>
                    <span>@found "dog"</span>
                  </div>
                  """
        JUMLY.scan nodes, finder:(nodes)-> nodes.find "span"
        expect(nodes.find("> .diagram").length).toBe 1
        expect(nodes.find("> *").length).toBe 2
