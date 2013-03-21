require "node-jquery"
RobustnessDiagramBuilder = require "RobustnessDiagramBuilder"

describe "RobustnessDiagramBuilder", ->

  describe "examples", ->

    describe "scripting", ->

      beforeEach ->
        @diagram = new RobustnessDiagramBuilder().build """
          @actor "user", -> @view "yahoo"
        """

      it "has two elements", ->
        expect(@diagram.find(".element").length).toBe 2


    describe "markup", ->

      beforeEach ->
        html = $ """
                 <li><i>An user<i> opens <i>yahoo</i> with his browser.</li>
                 """
        @diagram = new RobustnessDiagramBuilder().build html

      it "has two elements", ->
        expect(@diagram.find(".element").length).toBe 2


  describe "corner cases", ->

    describe "empty string", ->

      it "works well", ->
        diag = new RobustnessDiagramBuilder().build ""
