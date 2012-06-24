
describe "JUMLY", ->
  describe "Position", ->
    it "is stuff to position node"

    describe "", ->
      it "should be", ->
        diag = new JUMLY.Diagram
        a = $("<div>").css(width:100, height:50, padding:4, border:"solid 2px #888", position:"absolute")
        b = $("<div>").css(width:100, height:50, padding:4, border:"solid 2px #888", position:"absolute")
        diag.append(a)
            .append(b)
        $("body").append diag
        pos = new JUMLY.Position

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
  describe "position", ->
    it "should be", ->
      a = $("<div>").css(width:1, height:1, border:"solid 1px #888", position:"absolute")
      diag = new JUMLY.Diagram
      $("body").append diag.css(padding:3).append a
      margin_left = parseInt $("body").css("margin-left")

      expect(margin_left + 3).toBe a.offset().left
      expect(3).toBe a.position().left


  describe "width,innerWidth,outerWidth", ->
    it "should be", ->
      a = $("<div>").css(width:64, height:50, padding:4, border:"solid 2px #888", position:"absolute")
      $("body").append a

      expect(        64        ).toBe a.width()
      expect(    4 + 64 + 4    ).toBe a.innerWidth()
      expect(2 + 4 + 64 + 4 + 2).toBe a.outerWidth()

