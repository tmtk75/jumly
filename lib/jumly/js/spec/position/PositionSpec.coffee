describe "Position", ->
  it "is stuff to position node"

  setup_diagram = (css)->
    diag = new JUMLY.Diagram
    a = $("<div>").css width:100, height:50, padding:4, border:"solid 2px #e88", "background-color":"#fcc", opacity:0.77, position:"absolute"
    b = a.clone().css "border-color":"#8e8", "background-color":"#cfc", height:25, top:10
    c = a.clone().css width:50, height:20, "border-color":"#88e", "background-color":"#ccf"
    diag.addClass(css).append(a).append(b.append(c))
    $("body").append diag.addClass "spec"
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
      {css, diag} = setup "pos-top-77", "top:0px; top:77px"
      pos = new JUMLY.Position.Top css:css, dst:diag.dst
      pos.apply()
      pos = new JUMLY.Position.Top css:css, dst:diag.ext
      pos.apply()

      margin_top = diag.offset().top
      expect(margin_top + 77         ).toBe diag.dst.offset().top
      expect(margin_top + 77 + 2 + 77).toBe diag.ext.offset().top

      diag.css top:50
      pos = new JUMLY.Position.Top css:css, dst:diag.dst
      pos.apply()
      pos = new JUMLY.Position.Top css:css, dst:diag.ext
      pos.apply()
      expect(margin_top + 50 + 77         ).toBe diag.dst.offset().top
      expect(margin_top + 50 + 77 + 2 + 77).toBe diag.ext.offset().top

    it "should be", ->
      {css, diag} = setup "pos-top-47", "left:68px; width:13px; top:47px; height:16px; background-color:#222;"
      diag.offset top:205
      diag.dst.css top:50
      pos = new JUMLY.Position.Top css:css, dst:diag.ext
      pos.apply()

      expect(205 + 50              ).toBe diag.dst.offset().top
      expect(205 + 50 + 2 + 47     ).toBe diag.dst.find(".pos-top-47-position").offset().top
      expect(205 + 50 + 2 + 47 + 16).toBe diag.ext.offset().top


    describe "coordinate", ->
      it "should set coordinate", ->
        {css, diag} = setup "pos-top-coordinate-55", "top:0px; height:55px; background-color:#222; width:10px"
        (new JUMLY.Position.Top css:css, dst:diag.dst).apply()
        (new JUMLY.Position.Top css:css, dst:diag.ext, coordinate:diag).apply()

        margin_top = diag.offset().top
        expect(margin_top + 55).toBe diag.dst.offset().top
        expect(margin_top + 55).toBe diag.ext.offset().top


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



