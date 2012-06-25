
describe "JUMLY", ->
  describe "Position", ->
    it "is stuff to position node"

    setup_diagram = (css)->
      diag = new JUMLY.Diagram
      a = $("<div>").css width:100, height:50, padding:4, border:"solid 2px #e88", "background-color":"#fcc", opacity:0.77, position:"absolute"
      b = a.clone().css "border-color":"#8e8", "background-color":"#cfc", height:25, top:10
      c = a.clone().css width:50, height:20, "border-color":"#88e", "background-color":"#ccf"
      diag.addClass(css).append(a).append(b.append(c))
      $("body").append diag
      $.extend diag, src:a, dst:b, ext:c

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
        {css, diag} = setup "pos-rightleft-123", "width:123px"
        pos = new JUMLY.Position.RightLeft css:css, src:diag.src, dst:diag.dst
        diag.src.css left:8, top:10
        pos.apply()

        expect(8                          ).toBe diag.src.position().left
        expect(8 + (2*2 + 4*2 + 100) + 123).toBe diag.dst.position().left
        
        css = setup_style "pos-rightleft-0", "width:0px"
        pos = new JUMLY.Position.RightLeft css:css, src:diag.src, dst:diag.ext
        pos.apply()
        
        margin_left = parseInt $("body").css("margin-left")
        expect(-(123 + 2)).toBe diag.ext.position().left  ## 123 is width and 2 is border
        expect(margin_left + 8 + (2*2 + 4*2 + 100) + 0).toBe diag.ext.offset().left

    describe "LeftRight", ->
      it "should be", ->
        {css, diag} = setup "pos-leftright-160", "width:160px"
        pos = new JUMLY.Position.LeftRight css:css, src:diag.src, dst:diag.dst
        diag.src.css left:400, top:10
        diag.dst.css width:30 - (4*2 + 2*2)
        pos.apply()

        expect(400           ).toBe diag.src.position().left
        expect(400 - 160 - 30).toBe diag.dst.position().left

        css = setup_style "pos-leftright-0", "width:0px"
        pos = new JUMLY.Position.LeftRight css:css, src:diag.src, dst:diag.ext
        pos.apply()
        
        margin_left = parseInt $("body").css("margin-left")
        expect(margin_left + 400 - (diag.dst.offset().left + 2) - (50 + 4*2 + 2*2)).toBe diag.ext.position().left
        expect(margin_left + 400                                - (50 + 4*2 + 2*2)).toBe diag.ext.offset().left

    describe "Left", ->
      it "should be", ->
        {css, diag} = setup "pos-left-321", "left:0px; width:321px"
        pos = new JUMLY.Position.Left css:css, dst:diag.dst
        pos.apply()
        pos = new JUMLY.Position.Left css:css, dst:diag.ext
        pos.apply()

        margin_left = parseInt $("body").css("margin-left")
        expect(margin_left + 321          ).toBe diag.dst.offset().left
        expect(margin_left + 321 + 2 + 321).toBe diag.ext.offset().left

        diag.css left:50
        pos = new JUMLY.Position.Left css:css, dst:diag.dst
        pos.apply()
        pos = new JUMLY.Position.Left css:css, dst:diag.ext
        pos.apply()
        expect(margin_left + 50 + 321          ).toBe diag.dst.offset().left
        expect(margin_left + 50 + 321 + 2 + 321).toBe diag.ext.offset().left

      it "should be", ->
        {css, diag} = setup "pos-left-110", "left:68px; width:13px; background-color:#222; height:10px"
        diag.offset left:205
        diag.dst.css left:50
        pos = new JUMLY.Position.Left css:css, dst:diag.ext
        pos.apply()

        expect(205 + 50              ).toBe diag.dst.offset().left
        expect(205 + 50 + 2 + 68     ).toBe diag.dst.find(".pos-left-110-position").offset().left
        expect(205 + 50 + 2 + 68 + 13).toBe diag.ext.offset().left


      describe "coordinate", ->
        it "should set coordinate", ->
          {css, diag} = setup "pos-left-coordinate-55", "left:0px; width:55px; background-color:#222; height:10px"
          (new JUMLY.Position.Left css:css, dst:diag.dst).apply()
          (new JUMLY.Position.Left css:css, dst:diag.ext, coordinate:diag).apply()

          margin_left = parseInt $("body").css("margin-left")
          expect(margin_left + 55).toBe diag.dst.offset().left
          expect(margin_left + 55).toBe diag.ext.offset().left

    describe "Top", ->
      it "should be", ->
        {css, diag} = setup "pos-top-321", "top:0px; top:77px"
        pos = new JUMLY.Position.Top css:css, dst:diag.dst
        pos.apply()
        pos = new JUMLY.Position.Top css:css, dst:diag.ext
        pos.apply()

        margin_top = parseInt $("body").css("margin-top")
        expect(margin_top + 77         ).toBe diag.dst.offset().top
        expect(margin_top + 77 + 2 + 77).toBe diag.ext.offset().top

        diag.css top:50
        pos = new JUMLY.Position.Top css:css, dst:diag.dst
        pos.apply()
        pos = new JUMLY.Position.Top css:css, dst:diag.ext
        pos.apply()
        expect(margin_top + 50 + 77         ).toBe diag.dst.offset().top
        expect(margin_top + 50 + 77 + 2 + 77).toBe diag.ext.offset().top


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

