description "icon", ->
    scenario "exact styles", ->
        given "an iconified .object", ->
            @obj = ($.uml ".object", "Actor").iconify "actor",
                fillStyle  : 'blue'
                strokeStyle: 'black'
            @diag = $.uml(".sequence-diagram").append obj
            $("body").append diag
            {@styles} = obj.renderIcon()
        ## NOTE: following specs are based on the actual executed result.
        ##       NOT expected base.
        then_it "fillStyle", ->
            styles.fillStyle.shouldBe 'rgb(255, 255, 255)'
        then_it "strokeStyle", ->
            styles.strokeStyle.shouldBe 'rgb(128, 128, 128)'

    scenario "icon style", ->
        given "some iconified .objects", ->
            @view       = ($.uml ".object", "")      .iconify "view", strokeStyle:'blue', fillStyle:'#a0a0ff'
            @controller = ($.uml ".object", "")      .iconify "controller", strokeStyle:'orange', fillStyle:'yellow'
            @entity     = ($.uml ".object", "entity").iconify "entity", strokeStyle:'red', fillStyle:'#ffa0a0', shadowColor:'#aaa', shadowBlur:4
            @actor      = ($.uml ".object", "")      .iconify "actor", strokeStyle:'green', fillStyle:'#a0ffa0'
            @view      .appendTo $ "body"
            @controller.appendTo $ "body"
            @entity    .appendTo $ "body"
            @actor     .appendTo $ "body"
            @entity.find(".name").css border:"1px black solid"
        then_it "", ->

    scenario "exact styles", ->
        given "an iconified .object", ->
            @obj = ($.uml ".object", "Actor").iconify "actor"
            $("body").append $.uml(".sequence-diagram").append obj
        then_it "icon is centered about 20pixels", ->
            (obj.find(".name").offset().left + 20).shouldBeLessThan obj.find(".icon-container").offset().left

