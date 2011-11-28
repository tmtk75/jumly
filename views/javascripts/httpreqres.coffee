@found "HTTP Client", ->
    @message "request", "HTTP Server", ->
        @message "POST", "Application Server", ->
            @create "HTTP Session"
            @message "persist the session", "Database"
            @reply "session key on cookie", "HTTP Client"
