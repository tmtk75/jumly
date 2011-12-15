u = $.jumly
description "usecase-diagram", ->
    seqno = 0
    new_diag = ->
        diag = u ".usecase-diagram"
        diag.boundary "boundary#{seqno++}", ->
            @usecase "An usecase"
            @actor "User"
        .compose $ "body"
        diag

    description "width", ->

        it "should be packed for the insides", ->
            diag = new_diag()
            r = diag.find(".system-boundary").outerRight()
            l = diag.find(".actor").offset().left
            diag.width().shouldBeGreaterThan r - l
    
    description "height", ->

        it "should be packed for the insides", ->
            diag = new_diag()
            t = diag.find(".system-boundary").offset().top
            b = diag.find(".actor").outerBottom()
            diag.height().shouldBeGreaterThan b - t


    xdescription "", ->

        simple_one = u ".usecase", "simple use-case"
    
        it "should consist of following", ->
            simple_one.expect((e)->e.hasClass("usecase"))
                      .find(".icon").expect(length:1)
                          .find(".name").expect(length:1)
    
        text = """
            What are you thinking? This is kid-napping, isn't it? If you are getting so angry at the sub seat,
            already I don't worry about it :) Hidding my simple mind, ...
            """
    
        it "", ->
            diag  = u ".usecase-diagram"
            bound = u ".system-boundary", "jumly library"
            uc    = u ".usecase", text
            uc.appendTo bound.appendTo diag.appendTo $ "body"
    
            uc.pack()
            icon = uc.find ".icon"
            name = uc.find ".icon .name"
    
            name.css "margin-top":(icon.height() - name.height())/10*4
    
        it "is referrence", ->
            diag  = u ".usecase-diagram"
            bound = u ".system-boundary", "jumly library"
            act0  = u ".actor", "User"
            act1  = u ".actor", "Manager"
            uc0   = u ".usecase", "This is an use-case for jumly use-case diagram."
            uc1   = u ".usecase", """
                        You can open any files with this application, because the app is binary editor.
                        A description for an usecase can have any length text, which means it need to cut
                        the tail of text somewhere.
                        """
    
            bound.append uc0
            bound.append uc1
            diag.append act0
            diag.append act1
            diag.append bound
    
    
            diag.appendTo $ "body"
            diag.compose()
