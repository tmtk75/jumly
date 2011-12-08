jumly = $.jumly

describe "Refering", ->
  
  it "should be used with @_", ->
    diag = jumly ".use-case-diagram"
    diag.found "", ->
      @beforeCompose (e, d) ->
        d.foobar = 1
      @afterCompose (e, d) ->
        d.bizbuz = 2 if d.foobar is 1
    diag.compose()
    expect(diag.foobar).toBe 1
    expect(diag.bizbuz).toBe 2


describe "Curry", ->
  
  Function.prototype.curry = ->
    args = arguments
    self = this
    ->
      Array.prototype.unshift.apply arguments, args
      self.apply this, arguments

  it "should bind 1st arg", ->
    sum2 = (x, y)-> x + y
    expect(sum2.curry(10)(5)).toBe 15

  it "should bind 1st and 2nd args", ->
    mean3 = (a, b, c)-> (a + b + c)/3
    expect(mean3.curry(10, 20)(30)).toBe 20
    
  it "should bind 1st array", ->
    f = (a, b)-> a.push b; a
    expect(f.curry([1,2])(3)).toEqual [1,2,3]

  it "should bind instance method...", ->
    a =
      b: 2
      f: (x)-> x + this.b
    f = (obj)-> (args)-> obj.f.curry(3).apply obj, arguments
    expect(f(a)()).toBe 5


describe "Identifiable Derrective", ->
  
  it "should return equivalent object apart from id attribute", ->
    
    JUMLY
