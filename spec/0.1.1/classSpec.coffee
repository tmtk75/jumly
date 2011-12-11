describe "JUMLYHTMLElement", ->
  
  it "should construct itself for extendee", ->
    class Foo extends JUMLY.HTMLElement
    Foo::build = -> $("<div>").addClass("bar").html("I'm Foo.")
    foo = new Foo
    expect(foo.hasClass "bar").toBeTruthy()
    expect(foo.html()).toBe "I'm Foo."
