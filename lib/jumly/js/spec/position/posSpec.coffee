
describe "JUMLY", ->
  describe "Position", ->
    it "is stuff to position node"

    setup_diagram = (css)->
      diag = new JUMLY.Diagram
      a = $("<div>").css width:100, height:50, padding:4, border:"solid 2px #e88", "background-color":"#fcc", opacity:0.77, position:"absolute"
      b = a.clone().css "border-color":"#8e8", "background-color":"#cfc"
      diag.addClass(css).append(a).append(b)
      $("body").append diag
      $.extend diag, src:a, dst:b

    setup_style = (id, styles)->
      style = $("head style")
      style.text style.text() + " " + ".#{id}-position {#{styles}}"
      "#{id}-position"

    setup = (id, style)->
      diag = setup_diagram id
      css = setup_style id, style
      css:css, diag:diag

    describe "RightLeft", ->
      it "should be", ->
        {css, diag} = setup "pos-rightleft", "width:123px"
        pos = new JUMLY.Position.RightLeft css:css, src:diag.src, dst:diag.dst
        diag.src.css left:8, top:10
        pos.apply()

        expect(8                          ).toBe diag.src.position().left
        expect(8 + (2*2 + 4*2 + 100) + 123).toBe diag.dst.position().left

    describe "Left", ->
      it "should be", ->
        {css, diag} = setup "pos-left", "left:0px; width:321px"
        pos = new JUMLY.Position.Left css:css, dst:diag.dst
        pos.apply()

        expect(321).toBe diag.dst.position().left

    describe "LeftRight", ->
      it "should be", ->
        {css, diag} = setup "pos-leftright", "width:160px"
        pos = new JUMLY.Position.LeftRight css:css, src:diag.src, dst:diag.dst
        diag.src.css left:400, top:10
        diag.dst.css width:30 - (4*2 + 2*2)
        pos.apply()

        expect(400           ).toBe diag.src.position().left
        expect(400 - 160 - 30).toBe diag.dst.position().left


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

    it "should be", ->
      a = $("<div>").css(width:100, top:10, position:"absolute", "border":"solid 2px #48f")
      b = $("<div>").css(width:110, top:20, position:"absolute", "border":"solid 2px #4f8")
      c = $("<div>").css(width:120, top:30, position:"absolute", "border":"solid 2px #84f")
      d = $("<div>").css(width:130, top:40, position:"absolute", "border":"solid 2px #8f4")
      e = $("<div>").css(width:140, top:50, position:"absolute", "border":"solid 2px #f84")
      $("body").append(a)
      a.append(b)
       .append(c)
      c.append(d)
       .append(e)
      
      margin_left = parseInt $("body").css("margin-left")
      expect(margin_left).toBe a.position().left
      expect(margin_left).toBe a.offset().left

      b.css(left:20)
      c.offset(left:20)
      expect(20                    ).toBe b.position().left
      expect(20 - (2 + margin_left)).toBe c.position().left  ## 2 is thick of border-left
      expect(margin_left + 2 + 20).toBe b.offset().left
      expect(                  20).toBe c.offset().left
      
      d.css(left:30)
      e.offset(left:30)
      expect(30                        ).toBe d.position().left
      expect(30 - (2 + c.offset().left)).toBe e.position().left  ## 2 is thick of border-left
      expect(30 + c.offset().left + 2  ).toBe d.offset().left
      expect(30                        ).toBe e.offset().left

      b.offset(left:100)
      d.offset(left:100)
      expect(100 - (a.offset().left + 2)).toBe b.position().left
      expect(100 - (20 + 2)             ).toBe d.position().left

      c.offset(left:200)
      e.css(left:50)
      expect(          50).toBe e.position().left
      expect(200 + 2 + 50).toBe e.offset().left



  describe "width,innerWidth,outerWidth", ->
    it "should be", ->
      a = $("<div>").css(width:64, height:50, padding:4, border:"solid 2px #888", position:"absolute")
      $("body").append a

      expect(        64        ).toBe a.width()
      expect(    4 + 64 + 4    ).toBe a.innerWidth()
      expect(2 + 4 + 64 + 4 + 2).toBe a.outerWidth()

