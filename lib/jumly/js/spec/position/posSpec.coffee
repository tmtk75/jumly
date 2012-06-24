
describe "JUMLY", ->
  describe "Position", ->
    it "is stuff to position node"

    setup_diagram = (css)->
      diag = new JUMLY.Diagram
      a = $("<div>").css width:100, height:50, padding:4, border:"solid 2px #e88", "background-color":"#fcc", opacity:0.77, position:"absolute"
      b = a.clone().css "border-color":"#8e8", "background-color":"#cfc"
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
        expect(-1).toBe diag.ext.position().left
        expect(margin_left + 8 + (2*2 + 4*2 + 100) + 0).toBe diag.ext.offset().left
