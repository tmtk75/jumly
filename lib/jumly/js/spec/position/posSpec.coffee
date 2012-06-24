
describe "JUMLY", ->
  describe "Position", ->
    it "is stuff to position node"

    describe "", ->
      setup_diagram = (css)->
        diag = new JUMLY.Diagram
        a = $("<div>").css width:100, height:50, padding:4, border:"solid 2px #e88", "background-color":"#fcc", opacity:0.77, position:"absolute"
        b = a.clone().css "border-color":"#8e8", "background-color":"#cfc"
        diag.addClass(css)
            .append(a)
            .append(b)
        $("body").append diag
        diag.src = a
        diag.dst = b
        diag

      setup_style = (id, styles)->
        style = $("head style")
        style.text style.text() + " " + ".#{id}-position {#{styles}}"
        "#{id}-position"

      setup = (id, style)->
        diag = setup_diagram id
        css = setup_style id, style
        css:css, diag:diag

      it "should be", ->
        ctx = setup "pos-test-1", "width:123px"
        pos = new JUMLY.Position.RightLeft css:ctx.css, src:ctx.diag.src, dst:ctx.diag.dst
        ctx.diag.src.css left:8, top:10
        pos.apply()

        expect(8      ).toBe ctx.diag.src.position().left
        expect(8 + 2 + 4 + 100 + 4 + 2 + 123).toBe ctx.diag.dst.position().left


    xdescribe "horizontal", ->
      it "should be correct", ->
        $("body").append (new JUMLY.SequenceDiagramBuilder).build """
        @found a:"Boy", ->
          @message "call", b:"Mother", ->
        """
        $(".diagram").self().compose()
        a = $("#a")
        b = $("#b")
        packing = $(".horizontal.packing").width()

        expect(a.css "left").toBe "0px"
        expect(b.css "left").toBe (a.outerWidth() + packing) + "px"


describe "jQuery", ->
  describe "offset,position", ->
    it "should be", ->
      a = $("<div>").css(width:240, height:1, border:"solid 2px #88e", position:"absolute")
      diag = (new JUMLY.Diagram).addClass "offset-position"
      $("body").append diag.css(padding:16).append a
      margin_left = parseInt $("body").css("margin-left")

      expect(margin_left + 16).toBe a.offset().left
      expect(              16).toBe a.position().left


  describe "width,innerWidth,outerWidth", ->
    it "should be", ->
      a = $("<div>").css(width:64, height:50, padding:4, border:"solid 2px #888", position:"absolute")
      $("body").append a

      expect(        64        ).toBe a.width()
      expect(    4 + 64 + 4    ).toBe a.innerWidth()
      expect(2 + 4 + 64 + 4 + 2).toBe a.outerWidth()

