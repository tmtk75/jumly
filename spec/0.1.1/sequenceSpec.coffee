$ ->
  append = (a)-> $("body").append a
  describe "sequence", ->
    describe "show-case", ->
      builder = new JUMLY.SequenceDiagramBuilder
      builder.verbose = true
      dsl = """
            @found "An usual user", ->
              @message "render", "A diagram you want"
              @create slide:"A new slide", ->
                @message "init"
              @message "improve", slide
              window["An usual user"]      = an_usual_user
              window["A diagram you want"] = a_diagram_you_want
              window["A new slide"]        = slide
            """
      diag = builder.build dsl
      append diag
      diag.compose()

      it "should generate three objects", ->
        expect(diag.find(".object").length).toBe 3
        #console.log (e for e of diag)

      it "should create object for '#slide'", ->
        expect(diag["slide"]).not.toBeUndefined()

      it "should create object for '#an-usual-user'", ->
        expect(diag["an-usual-user"]).toBeUndefined()
        expect(diag["an_usual_user"]).not.toBeUndefined()

      it "should create object for '#a-diagram-you-want'", ->
        expect(diag["a-diagram-you-want"]).toBeUndefined()
        expect(diag["a_diagram_you_want"]).not.toBeUndefined()

      it "should not create object for '#a-new-slide'", ->
        expect(diag["a-new-slide"]).toBeUndefined()
        expect(diag["a_new_slide"]).toBeUndefined()

      it "should make refer to the object", ->
        byid  = diag.find("#slide").self()
        byref = diag.slide
        expect(byid).toBe byref

      it "should equal to for an_usual_user", ->
        expect(window["An usual user"]).toBe diag.find("#an-usual-user").self()

      it "should equal to for a_diagram_you_want", ->
        expect(window["A diagram you want"]).toBe diag.find("#a-diagram-you-want").self()

      it "should equal to for slide", ->
        expect(window["A new slide"]).toBe diag.find("#slide").self()

    
    describe "@found", ->
      it "should assign an ID", ->
        b = new JUMLY.SequenceDiagramBuilder
        d = b.build "@found seq_found:'A'"
        expect(d.seq_found).toBe d.find("#seq_found").self()
        expect(d.seq_found.hasClass "object").toBeTruthy()


    describe "@create", ->
      it "should assign an ID for identified value", ->
        b = new JUMLY.SequenceDiagramBuilder
        diag = b.build """
                       @found abcd12234844:"A", ->
                         @create "create-spec-1":"something name"
                         window.createdVariable = create_spec_1
                       """
        a = diag.find("#create-spec-1.object").self()
        expect(a.length).toBe 1
        expect(window.createdVariable).toBe a
        expect(diag.find(".object:eq(1) .name").text()).toBe "something name"

      it "should identify with the ID not the name", ->
        b = new JUMLY.SequenceDiagramBuilder
        diag = b.build """
                       @found "Seakyld0022", ->
                         @create "Edenbird0011":"Kyldylym0011"
                       """
        expect(diag.find(".object").length).toBe 2
        expect(diag.find(".object:eq(0)").attr("id")).toBe "seakyld0022"
        expect(diag.find(".object:eq(0) .name").text()).toBe "Seakyld0022"
        expect(diag.find(".object:eq(1)").attr("id")).toBe "Edenbird0011"
        expect(diag.find(".object:eq(1) .name").text()).toBe "Kyldylym0011"
        expect(diag.find("#Edenbird0011").self()).toBe diag.find(".object:eq(1)").self()
        expect(diag.find("#kyldylym0011").length).toBe 0


    describe "@message", ->
      it "should refer to the object having same id if a string is given at 2nd argument", ->
        b = new JUMLY.SequenceDiagramBuilder
        b.verbose = true
        diag = b.build """
                       @found abcd13241234:"Root Object", ->
                         @message "call-1", "New Object 1234"
                         @message "call-2", "New Object 1234"
                       """
        expect(diag.find(".object").length).toBe 2


    describe "layout", ->
      describe "diagram", ->
        describe "width-height", ->
          it "depends on most-edges of children"
        describe "left-top", ->
      describe "object", ->
        describe "width-height", ->
        describe "left-top", ->
      describe "occurrence", ->
        describe "width-height", ->
        describe "left-top", ->


    it "should work well for 2011-12-25 23:11", ->
      b = new JUMLY.SequenceDiagramBuilder
      b.verbose = true
      diag = b.build """
        @found "You", ->
          @message "Think", ->
            @message "Write your idea", "JUMLY", ->
              @create "S Node"
        """
      append diag
      diag.compose()
      expect(diag.find("#you"   ).attr "id").toBe "you"
      expect(diag.find("#jumly" ).attr "id").toBe "jumly"
      expect(diag.find("#s-node").attr "id").toBe "s-node"
      expect(diag["you"]   ).not.toBeUndefined()
      expect(diag["jumly"] ).not.toBeUndefined()
      expect(diag["s_node"]).not.toBeUndefined()
      expect(diag.find(".object").length).toBe 3

    it "should work well for 2011-12-26 07:36", ->
      save = JUMLY.Diagram.isRefExisting
      delete JUMLY.Diagram.isRefExisting

      b = new JUMLY.SequenceDiagramBuilder
      diag = b.build """@found "Foxixen", ->"""
      append diag
      b = new JUMLY.SequenceDiagramBuilder
      diag = b.build """@found "Foxixen", ->"""

      JUMLY.Diagram.isRefExisting = save

###
Layout for 2D digram is deciding left-top and width-height at all.
Generally,
  - left-top is usually given by others like parent node.
  - width-height depends on child nodes.
Exceptionally,
  - width-height may be fixed.
  - Own width-height may be required in order to layout own children for centering.
As possible,
  - Not active layout, want to delegate layout to each child node.
###
