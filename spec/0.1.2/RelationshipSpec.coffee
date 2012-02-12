describe "JUMLYRelationship", ->
  
  it "should has .name just after creation", ->
    a = src:{}, dst:{}
    r = new JUMLY.Relationship a
    expect(r.find(".name").length).toBe 1
    expect(r.src).toBe a.src
    expect(r.dst).toBe a.dst
