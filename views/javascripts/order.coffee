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
        diag["Customer"]    .iconify "actor"
        diag["Order"]       .iconify "view"
        diag["Menu Manager"].iconify "controller"
        diag["Database"]    .iconify "entity"
        diag["Menu Manager"].lost()
        diag.addClass("theme-pop")
        
