u = $.jumly
description "use-case-diagram", ->

    new_diag = ->
        diag = u ".use-case-diagram"
        diag.boundary "boundary", ->
            @usecase "An use-case"
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

        simple_one = u ".use-case", "simple use-case"
    
        it "should consist of following", ->
            simple_one.expect((e)->e.hasClass("use-case"))
                      .find(".icon").expect(length:1)
                          .find(".name").expect(length:1)
    
        text = """
            What are you thinking? This is kid-napping, isn't it? If you are getting so angry at the sub seat,
            already I don't worry about it :) Hidding my simple mind, ...
            """
    
        it "", ->
            diag  = u ".use-case-diagram"
            bound = u ".system-boundary", "jumly library"
            uc    = u ".use-case", text
            uc.appendTo bound.appendTo diag.appendTo $ "body"
    
            uc.pack()
            icon = uc.find ".icon"
            name = uc.find ".icon .name"
    
            name.css "margin-top":(icon.height() - name.height())/10*4
    
        it "is referrence", ->
            diag  = u ".use-case-diagram"
            bound = u ".system-boundary", "jumly library"
            act0  = u ".actor", "User"
            act1  = u ".actor", "Manager"
            uc0   = u ".use-case", "This is an use-case for jumly use-case diagram."
            uc1   = u ".use-case", """
                        You can open any files with this application, because the app is binary editor.
                        A description for an use-case can have any length text, which means it need to cut
                        the tail of text somewhere.
                        """
    
            bound.append uc0
            bound.append uc1
            diag.append act0
            diag.append act1
            diag.append bound
    
    
            diag.appendTo $ "body"
            diag.compose()
