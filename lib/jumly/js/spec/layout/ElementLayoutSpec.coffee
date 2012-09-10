describe "ElementLayout", ->
  describe "Horizontal", ->
    it "should be ", ->
      diag = new JUMLY.Diagram
      a = $("<div>")
      b = $("<div>")
      diag.append(a.addClass "spec-object")
          .append(b.addClass "spec-object")
          .addClass("horizontal-spacing-spec-1")
      $("body").append diag

      $("head").append $("<style>").html """
        .horizontal-spacing-spec-1 .horizontal.spacing {width:123px;}
        .spec-object {width:100px; height:10px; border:solid 1px #444;}
        """

      spacing = new JUMLY.HorizontalSpacing(a, b)
      spacing.apply()

      left = a.offset().left + a.outerWidth() + 123 + 1
      expect(left).toBe b.offset().left
      expect(diag.find(".spacing").length).toBe 1

      spacer = diag.find(".spacing:eq(0)")
      expect(spacer.offset().left).toBe a.offset().left + a.outerWidth()
      expect(spacer.offset().top).toBe a.offset().top

      # apply again
      spacing.apply()
      expect(left).toBe b.offset().left
      expect(diag.find(".spacing").length).toBe 1

