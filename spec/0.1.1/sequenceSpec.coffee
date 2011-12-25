$ ->
  append = (a)-> $("body").append a
  describe "sequence", ->
    describe "show-case", ->
      builder = new JUMLY.SequenceDiagramBuilder
      dsl = """
            @found "An usual user", ->
              @message "render", "A diagram you want"
              @create slide:"A new slide", ->
                @message "init"
              @message "improve", slide
            @diagram.slide = slide
            """
      diag = builder.build dsl
      append diag
      diag.compose()

      it "should make refer to the object", ->
        byid  = diag.find("#a-new-slide")
        byref = diag.slide
        expect(byid).toBe byref

    
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
                       """
        expect(diag.find("#create-spec-1").length).toBe 1
        expect(diag.find(".object:eq(1) .name").text()).toBe "something name"


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
