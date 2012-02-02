## /TryJUMLY's sample data
JUMLY.TryJUMLY.samples =
  "sample-1":"""
  ## A basic sample
  @found "You", ->
    @message "use", "JUMLY", ->
      @create "Diagram"
  """
  "sample-2":"""
    @found "You", ->
      @message "use", "JUMLY"
      @message "write", "JUMLY", ->
        @create "Diagram"
        @reply "", "You"
    you.iconify "actor"
    diagram.iconify "entity"
    jumly.iconify "controller"
    
    @after (e, d)->
      $(".tooltip").remove()
      tipbody = "includes&nbsp;some<br>" +
                "JavaScript&nbsp;files"
      d.find(".occurrence:eq(1)")
       .attr(title:tipbody,"data-placement":'right')
       .tooltip("show")
    """ 
  "sample-3":"""
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
      page.attr(title:"Bootstrap Tooltip")
          .twipsy(placement:"right",trigger:'manual')
          .twipsy('show')
      tiptext = '''
        Tooltip is better<br/>
        when note is exaggerated'''
      diag.find(".occurrence:eq(5)")
          .attr(title:tiptext)
          .twipsy(html:true)
          .twipsy(trigger:'manual',placement:"right")
          .twipsy('show')
    """
  "sample-4":"""
    @found "You", ->
      @create "Diagram"
      @message "show URL", "JUMLY", ->
        @message "generate short URL", "bit.ly", ->
          @reply "", "JUMLY"
        @message "show&nbsp;the URL", ->
        @reply "", "You"
      @message "copy it"
      @ref "Easy Draw, Easy Share!!!"
    ref = @diagram.find(".ref .name")
    ref.css "font-weight":"bold", "font-size":"large"
    """
  "sample-5":"""
    @found "you", ->
      @message "Login", "Gmail", ->
      @create "sign-up", "Facebook account", ->
    
    gmail_logo = '<img src="http://www.sizlotech.com/wp-content/uploads/2011/11/Super_Gmail_Logo1-625x462.png" width="44"/>'
    fb_logo = '<img src="http://burberry-tiepin.x0.com/wp-content/uploads/2012/01/facebook300x300.png" width="44"/>'
    
    you.iconify "actor"
    @diagram.find(".object .name").css(border:"none", "background":"none", "box-shadow":"none")
    gmail.find(".name").append("<br>"+gmail_logo)
    facebook_account.find(".name").append(fb_logo)
    
    @diagram.append $("<div>").css(position:"absolute",right:0,top:0,width:"44%",border:"solid 1px rgba(0,32,64,.2)","border-radius":"3px",padding:"4px 0.5em 4px 1em",background:"rgba(0,32,80,0.4)",color:"white","box-shadow":"2px 1px 2px 1px gray").html "You can append anything and customize looks using CSS/jQuery syntax you are familiar with whenever you want."
    """
