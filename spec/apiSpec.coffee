self = require: unless typeof require is "undefined" then require else JUMLY.require

self.require "node-jquery"
core = self.require "core"
self.require "api"

describe "JUMLY", ->

  describe "eval", ->
    beforeEach ->
      @node = $ '''<span><div data-jumly='{"type":"text/jumly+sequene"}'>@found "that"</div></span>'''
      @here = $ """<div><span></span></div>"""

    describe "a jQuery node is given", ->
      describe "with `into`", ->
        it "makes a new diagram and put it", ->
          a = JUMLY.eval @node, into:@here
          b = @here.find ">.diagram"
          expect(b.length).toBe 1
          expect(a[0]).toBe b[0]

      describe "with a funciton `placer`", ->
        it "makes a new diagram and put it", ->
          a = JUMLY.eval @node, (d, $e)=> @here.find(">span").append d
          b = @here.find ">span>.diagram"
          expect(b.length).toBe 1
          expect(a[0]).toBe b[0]

    describe "a string is given", ->

      describe "with `into`", ->
        it "makes a new diagram and put it", ->
          a = JUMLY.eval "@found 'cat'", into:@here
          b = @here.find ">.diagram"
          expect(b.length).toBe 1
          expect(a[0]).toBe b[0]

      describe "with a funciton `placer`", ->
        it "makes a new diagram and put it", ->
          a = JUMLY.eval "@found 'dog'", (d, $e)=> @here.find(">span").after d
          b = @here.find ">*:eq(1)"
          expect(b.hasClass "diagram").toBeTruthy()
          expect(a[0]).toBe b[0]


  describe "scan", ->

    describe "a jQuery nodeset is given", ->
      it "makes a new diagram after each node which has data-jumly attr", ->
        nodes = $ """
                  <div>
                    <div data-jumly='{"type":"text/jumly+sequene"}'>@found "that"</div>
                  </div>
                  """
        JUMLY.scan nodes.find("> *")
        expect(nodes.find("> .diagram").length).toBe 1

      describe "with opiton", ->

        describe "which has an funciton placer", ->
          nodes = $ """
                    <div>
                      <div data-jumly="text/jumly+sequene">@found "dog"</div>
                    </div>
                    """
          JUMLY.scan nodes, placer:(d, $e)-> nodes.html d
          expect(nodes.find("> .diagram").length).toBe 1
          expect(nodes.find("> *").length).toBe 1

    describe "call twice", ->

      describe "for a single script in scope", ->

        nodes = """
                <div>
                  <script id='a-script' type="text/jumly+sequene">@found "cat"</script>
                </div>
                """

        it "doesn't create more than 1", ->
          nodes = $(nodes)
          scripts = nodes.find("> script, > *[data-jumly]")
          JUMLY.scan scripts
          JUMLY.scan scripts
          expect(nodes.find("> .diagram").length).toBe 1

        describe "when modifying code", ->
          beforeEach ->
            @nodes = $(nodes)
            @scripts = nodes.find("> script")

            JUMLY.scan @scripts
            @nodes.find("script").text "@found 'bird'"

          describe "without eval", ->
            it "doesn't eval again", ->
              JUMLY.scan @scripts  # scan again

              expect(@nodes.find("> .diagram").length).toBe 1
              expect(@nodes.find("> .diagram .participant").text()).toBe "cat"

          describe "with eval", ->
            it "evals", ->
              JUMLY.scan @scripts, synchronize:true  # scan again with re-eval

              expect(@nodes.find("> .diagram").length).toBe 1
              expect(@nodes.find("> .diagram .participant").text()).toBe "bird"


      describe "for a single div in scope", ->

        nodes = """
                <div>
                  <div id='a-div' data-jumly="text/jumly+sequene">@found "cat"</script>
                </div>
                """

        it "doesn't create more than 1", ->
          nodes = $(nodes)
          scripts = nodes.find("> script, > *[data-jumly]")
          JUMLY.scan scripts
          JUMLY.scan scripts
          expect(nodes.find("> .diagram").length).toBe 1

      describe "for multi-nodes in scope", ->

        nodes = """
                <div>
                  <script id='a-script' type="text/jumly+sequene">@found "cat"</script>
                  <div id='a-div' data-jumly="text/jumly+sequene">@found "cat"</div>
                </div>
                """

        it "doesn't create more than 1", ->
          nodes = $(nodes)
          scripts = nodes.find("> script, > *[data-jumly]")
          JUMLY.scan scripts
          JUMLY.scan scripts
          expect(nodes.find("> .diagram").length).toBe 2
