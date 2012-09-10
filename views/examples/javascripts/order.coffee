@found "Customer", ->
  @create "Order"
  @loop @message "Add Item", "Order", ->
    @message "Check Available", "Menu Manager", ->
      @message "a Callback", "Order", ->
        @message "a self message"
      @message "an async request", "Order", ->
        @reply ""
    @reply ""
  @message "End Order", "Order", ->
    @loop @message "", "Menu Manager", ->
      @message "Commit", "Database", ->
        @destroy "Order"
  @ref "Complete Order and Pay"
  @beforeCompose (e, diag) ->
    diag["customer"]    .iconify "actor"
    diag["order"]       .iconify "view"
    diag["menu_manager"].iconify "controller"
    diag["database"]    .iconify "entity"
    #diag["menu_manager"].lost()
    diag.addClass("theme-pop")
