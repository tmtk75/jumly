
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

