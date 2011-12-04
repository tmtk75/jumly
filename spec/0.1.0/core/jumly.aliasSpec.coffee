description "alias", ->
    f = $.uml.alias
    it "should be first char", ->
        f("ab").shouldBe "a"
    it "should be first char and lower case", ->
        f("Ab").shouldBe "a"
    it "a", ->
        f("a b").shouldBe "ab"
    it "b", ->
        f("a  b").shouldBe "ab"
    it "c", ->
        f("a  B").shouldBe "ab"
    it "d", ->
        f("AB C").shouldBe "ac"
    it "e", ->
        f("a b c").shouldBe "abc"
    it "f", ->
        f("a-b-c").shouldBe "abc"



    description "use-case", ->
    
        scenario "", ->
            given "a use-case diagram", ->
                diag = $.uml ".use-case-diagram"
            when_it "", ->
