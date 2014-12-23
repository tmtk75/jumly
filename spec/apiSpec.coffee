core = require "core.coffee"
JUMLY = require "api.coffee"
$ = require "jquery"

describe "JUMLY", ->

  describe "eval", ->
    beforeEach ->
      @node = $ '''<span><div data-jumly='{"type":"text/jumly+sequence"}'>@found "that"</div></span>'''
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

    ## Disable string argument
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

    describe "text/jumly+robustness", ->
      describe "in type of script", ->
        it "makes a new robustness diagram", ->
          node = $ '''<script type='text/jumly+robustness'>@actor "User"</script>'''
          a = JUMLY.eval node, into:@here
          expect(a.hasClass "robustness-diagram").toBeTruthy()
          expect(@here.find(">.diagram").length).toBe 1

      describe "in data-jumly", ->
        describe "as string", ->
          it "makes a new robustness diagram", ->
            node = $ '''<div data-jumly='text/jumly+robustness'>@view "Browser"</div>'''
            a = JUMLY.eval node, into:@here
            expect(a.hasClass "robustness-diagram").toBeTruthy()

        describe "as object", ->
          it "makes a new robustness diagram", ->
            node = $ '''<div data-jumly='{"type":"text/jumly+robustness"}'>@view "Browser"</div>'''
            a = JUMLY.eval node, into:@here
            expect(a.hasClass "robustness-diagram").toBeTruthy()


  describe "scan", ->

    beforeEach ->
      @finder = (a)->a.find("> *")

    describe "a jQuery nodeset is given", ->
      it "makes a new diagram after each node which has data-jumly attr", ->
        nodes = $ """
                  <div>
                    <div data-jumly='{"type":"text/jumly+sequence"}'>@found "that"</div>
                  </div>
                  """
        JUMLY.scan nodes, finder:@finder
        expect(nodes.find("> .diagram").length).toBe 1

      describe "with opiton", ->

        it "has an function placer", ->
          nodes = $ """
                    <div>
                      <div data-jumly="text/jumly+sequence">@found "dog"</div>
                    </div>
                    """
          JUMLY.scan nodes, finder:@finder, placer:(d, $e)-> nodes.html d
          expect(nodes.find("> .diagram").length).toBe 1
          expect(nodes.find("> *").length).toBe 1

    describe "call twice", ->

      describe "for a single script in scope", ->

        nodes = """
                <div>
                  <script id='a-script' type="text/jumly+sequence">@found "cat"</script>
                </div>
                """

        it "doesn't create more than 1", ->
          nodes = $(nodes)
          JUMLY.scan nodes
          JUMLY.scan nodes
          expect(nodes.find("> .diagram").length).toBe 1

        describe "when modifying code", ->
          beforeEach ->
            @nodes = $(nodes)
            JUMLY.scan @nodes, finder:(n)->n.find("> script")
            @nodes.find("script").text "@found 'bird'"

          describe "without eval", ->
            it "doesn't eval again", ->
              JUMLY.scan @nodes # scan again

              expect(@nodes.find("> .diagram").length).toBe 1
              expect(@nodes.find("> .diagram .participant").text()).toBe "cat"

          describe "with eval", ->
            it "evals", ->
              JUMLY.scan @nodes, synchronize:true  # scan again with re-eval

              expect(@nodes.find("> .diagram").length).toBe 1
              expect(@nodes.find("> .diagram .participant").text()).toBe "bird"


      describe "for a single div in scope", ->

        nodes = """
                <div>
                  <div id='a-div' data-jumly="text/jumly+sequence">@found "cat"</script>
                </div>
                """

        it "doesn't create more than 1", ->
          nodes = $(nodes)
          JUMLY.scan nodes
          JUMLY.scan nodes
          expect(nodes.find("> .diagram").length).toBe 1

      describe "for multi-nodes in scope", ->

        nodes = """
                <div>
                  <script id='a-script' type="text/jumly+sequence">@found "cat"</script>
                  <div id='a-div' data-jumly="text/jumly+sequence">@found "cat"</div>
                </div>
                """

        it "doesn't create more than 1", ->
          nodes = $(nodes)
          JUMLY.scan nodes
          JUMLY.scan nodes
          expect(nodes.find("> .diagram").length).toBe 2

      describe "one by one", ->
        it "makes diagrams properly", ->
          nodes = $ """
                    <div>
                      <script id='a-script' type="text/jumly+sequence">@found "cat"</script>
                    </div>
                    """
          JUMLY.scan nodes
          nodes.append '''<div id='a-div' data-jumly="text/jumly+sequence">@found "cat"</div>'''
          JUMLY.scan nodes
          expect(nodes.find("> .diagram").length).toBe 2
