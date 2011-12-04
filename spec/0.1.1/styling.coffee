
d = $.jumly

describe "Styling with CSS", ->
  
  it "", ->
    diag = d ".use-case-diagram"
    diag.found "", ->
      @beforeCompose (e, d) ->
        d.foobar = 1
      @afterCompose (e, d) ->
        d.bizbuz = 2 if d.foobar is 1
    diag.compose()
    expect(diag.foobar).toBe 1
    expect(diag.bizbuz).toBe 2
