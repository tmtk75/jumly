that = exports ? this
describe "commons", ->
    beforeEach =>
        that.obj = $.uml ".object"

    it "should have name", ->
        expect(that.obj.name).toBeDefined()
    it "should be function", ->
        expect(typeof that.obj.name).toBe "function"
    it "should store value", ->
        that.obj.name 'Taro'
        expect(that.obj.name()).toBe 'Taro'

    description "mostLeftRight", ->
        scenario "unattached node", ->
            given "a div", ->
                @div = $("<div>").append($("<div>"))
            when_it "get the metrix", ->
                @a = $("div", div).mostLeftRight()
            then_it "0", ->
                expect(0).toBe @a.left
            then_it "should be outerWidth of the inside object", ->
                w = $("div", div).outerWidth()
                expect(w).toBe @a.right
            then_it "should occupy 1px", ->
                expect(1).toBe @a.width()

        scenario "node under body", ->
            given "three objects", ->
                div = $("<div>")
                        .append($("<div>").width(100).offset left:0)
                        .append($("<div>").width(100).offset left:100 + 50)
                        .append($("<div>").width(100).offset left:100 + 50 + 100 + 50)
                        .find("div").css("position", "absolute").end()
                $("body").append div
                @a = $("div", div).mostLeftRight()
            then_it "left", ->
                expect(a.left).toBe 0
            then_it "right", ->
                a.right.shouldBe 100 + 50 + 100 + 50 + 100 - 1
            then_it "width", ->
                a.width().shouldBe 100 + 50 + 100 + 50 + 100

    describe "name, stereotype", ->
        it "should be function", ->
            that.obj = $.uml(".object")
            expect(typeof that.obj.name).toBe 'function'
            expect(typeof that.obj.stereotype).toBe 'function'
    
        beforeEach ->
            that.obj = $.uml(".object")
    
        it "shouldn't call other methods", ->
            that.obj.name('Taro')
                    .stereotype('racer')
            n = that.obj.name()
            m = that.obj.stereotype()
            expect(typeof n).toBe 'string'
            expect(typeof m).toBe 'string'
            expect(n).toBe 'Taro'
            expect(m).toBe 'racer'
    
        it "shouldn't call other methods", ->
            that.obj.name('Jiro')
                    .stereotype('engineer')
            expect(that.obj.name()).toBe 'Jiro'
            expect(that.obj.stereotype()).toBe 'engineer'
        
        it "should call compose", ->
            diag = $.uml(".sequence-diagram")
            spyOn diag, "compose"
            diag.compose()
            expect(diag.compose).toHaveBeenCalledWith()

    description "pickup2", ->
        shared_behavior "pick up 2 nodes", ->
            given "4 divs in a div", ->
                @div = $("<div>").append($("<div>").addClass "a")
                                 .append($("<div>").addClass "b")
                                 .append($("<div>").addClass "c")
                                 .append($("<div>").addClass "d")
            when_it "pick up by 2", ->
                @a1 = []
                f0 = (a) -> @a0 = a
                f1 = (a, b, i) -> @a1.push a:a, b:b, i:i
                $("div", div).pickup2 f0, f1

        scenario "pick up 2 nodes", ->
            it_behaves_as "pick up 2 nodes"
            then_it "three nodes are in the @a", ->
                @a0.hasClass("a").shouldBe true
                @a1.length.shouldBe 3
            and_ "for [0]", ->
                e = @a1[0]
                e.a.hasClass("a").shouldBe true
                e.b.hasClass("b").shouldBe true
                e.i.shouldBe 1
            and_ "for [1]", ->
                e = @a1[1]
                e.a.hasClass("b").shouldBe true
                e.b.hasClass("c").shouldBe true
                e.i.shouldBe 2
            and_ "for [2]", ->
                e = @a1[2]
                e.a.hasClass("c").shouldBe true
                e.b.hasClass("d").shouldBe true
                e.i.shouldBe 3

        scenario "empty node set", ->
            when_it "select empty", ->
                @a = $("span", div)
            then_it "nothing happens", ->
                f0 = -> throw "a"
                f1 = -> throw "b"
                @a.pickup2 f0, f1

        scenario "1 node set", ->
            when_it "select one node", ->
                @a = $(".a", div)
            then_it "nothing happens", ->
                f0 = ->
                f1 = -> throw "b"
                @a.pickup2 f0, f1
        
        scenario "3rd closure", ->
            when_it "select one node", ->
                @callcount = 0
                f = -> @callcount++
                g = (a, b, i) ->
                    @a = a:a, b:b, i:i
                $("div", div).pickup2 f, f, g
            then_it "3rd closure is called for the last set", ->
                @a.a.hasClass("c").shouldBe true
                @a.b.hasClass("d").shouldBe true
                @a.i.shouldBe 3
            and_ ->
                @callcount.shouldBe 3  # except for the last node

    description "constructor", ->
        scenario "name by string", ->
            given "an object with a string at 2nd args", ->
                @a = $.uml ".object", "foobar"
            then_it "name() is", ->
                a.name().shouldBe 'foobar'
            then_it "should have a node", ->
                a.find(".name").text().shouldBe 'foobar'

        scenario "name by object", ->
            given "an object with param", ->
                @a = $.uml ".object", name:"foobar"
            then_it "name() is", ->
                a.name().shouldBe 'foobar'
            then_it "should have a node", ->
                a.find(".name").text().shouldBe 'foobar'

    it "has some types", ->
        canvas = $("<canvas>")
                     .appendTo($ "body")
                     .attr(width: 386, height: 80*8)[0]
        ctxt = canvas.getContext('2d')
        y = 0
        g = (s) ->
            y += 80
            $.g2d.arrow ctxt, {x:0, y:y}, {x:380, y:y}, {shape:s, shadowColor:'rgba(0,0,0,0.33)', shadowBlur:4, shadowOffsetX:10, shadowOffset:5}
        g 'both'
        g 'line'
        g 'line2'
        g 'dashed'
        g 'dashed2'
        g 'normal'

    it "should return mostleft", ->
        a = $("<div id='foo'>").css(position:"absolute", left:0, top:0, width:100, height:50, border:"1px red solid", "mergin-left":5).offset(left:25)
        b = $("<div id='bar'>").css(position:"absolute", left:0, top:0, width:100, height:50, border:"1px green solid", "padding-right":10).offset(left:50, top:25)
        $("body").append a
        $("body").append b
        mlr = $("#foo, #bar").mostLeftRight()
        mlr.left.shouldBe 25
        mlr.right.shouldBe 161
        mlr.width().shouldBe 137

    description "mostLeftRight", ->
        it "should be 0 for left/right", ->
            lr = $("<div>").mostLeftRight()
            expect(lr.left).toBe 0
            expect(lr.right).toBe 0

