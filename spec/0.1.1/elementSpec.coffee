JUMLY = (require "../jumly").JUMLY
describe "JUMLYHTMLElement", ->
  
  it "should construct itself for extendee", ->
    class Foo extends JUMLY.HTMLElement
    Foo::_build_ = (div)-> div.addClass("bar").html("I'm Foo.")
    foo = new Foo
    expect(foo.hasClass "bar").toBeTruthy()
    expect(foo.html()).toBe "I'm Foo."

  it "should add a class after the class-name", ->
    class MyFooClass extends JUMLY.HTMLElement
    expect((new MyFooClass).hasClass "myfooclass") 

  it "should pass all arguments to _build_", ->
    class MyBar extends JUMLY.HTMLElement
    MyBar::_build_ = (div, a, b, c)->
      @me = div
      @_a_ = a
      @_b_ = b
      @_c_ = c
    bar = new MyBar(123, "abc")
    expect(bar.me).toBe bar
    expect(bar._a_).toBe 123
    expect(bar._b_).toBe "abc"
    expect(bar._c_).toBeUndefined()
