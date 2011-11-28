@found "Customer", ->
    @message "ask", "Hole Staff", ->
        @message "find a handy terminal", ->
    @message "order a set menu", "Hole Staff", ->
        @loop @message "input the order", "Handy Terminal", ->
            @create "Order", ->
                @message "validate the pair"
            @message "tell the order", "Kitchen Staff", ->
                @create "cook", "Set Menu", ->
                @message "validate"
                @message "tell", "Order", ->
                    @message asynchronous:"notify", "Handy Terminal"
                @reply "tell", "Hole Staff"
                @destroy "Order"
        @message asynchronous:"check", "Handy Terminal", ->
        @message "provide the dish", "Customer", ->
    @message "eat"
    @ref "Pay and go out"
    @beforeCompose (e, diag) ->
        diag["Kitchen Staff"].lost()
        diag["Handy Terminal"].iconify "view"
        $("html").addClass $.client.os

