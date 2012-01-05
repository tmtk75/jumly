## /TryJUMLY's sample data
JUMLY.TryJUMLY =
  samples:
    "sample-1":"""
      @found "You", ->
        @message "use", "JUMLY"
        @message "write", "JUMLY", ->
          @create "Diagram"
          @reply "", "You"
      you.iconify "actor"
      diagram.iconify "entity"
      jumly.iconify "controller"
      
      @after (e, d)->
        d.find(".occurrence:eq(1)")
         .twipsy("includes&nbsp;some&nbsp;" +
                 "JavaScript&nbsp;files", "right")
      """ 
    "sample-2":"""
      @found "You", ->
        @message "open", "Front Cover"
        @loop ->
          @alt
            "[page > 0]": -> @message "flip", "Page"
            "[page = 0]": -> @message "stop reading"
          @message "read", "Page"
        @message "close", "Front Cover"
        @ref "Tidy up book at shelf"
      
      @after (e, diag)->
        page.twipsy("Bootstrap Tooltip", "right")
        tiptext = '''
          Tooltip is better<br/>
          when note is exaggerated'''
        diag.find(".occurrence:eq(5)")
            .twipsy(tiptext, "right")
            .css("white-space":"nowrap")
      """
