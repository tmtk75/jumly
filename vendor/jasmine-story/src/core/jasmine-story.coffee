that = this

console = @console or ->

shared_behaviors = {}
current =
    description: null
    suite: null

validate_args = (desc, func) ->
    alertAndThrow "description is null or undefined"  if desc == null or desc == undefined
    alertAndThrow "'" + desc + "': function is undefiend"  if func == undefined

showNotification = (msg) ->
    n = window.webkitNotifications
    if n.checkPermission() > 0
        n.requestPermission showNotification
    else
        iconurl = ""
        title = ""
        p = n.createNotification(iconurl, title, msg)
        p.show()

consolelog = (msg) ->
    console.log "FATAL:" + msg, "from jasmine-story"

alertlog = (msg) ->
    @alert "FATAL:" + msg + " from jasmine-story"

alertAndThrow = (msg) ->
    log = alertlog
    if @jQuery
        body = $("body")
        if body.length > 0
            body.prepend $("<div>").text(msg)
        else
            log msg
    else if @alert
        
    else if @document and @document.getElementsByTagName
        body = @document.getElementsByTagName("body")
    else log msg  if @console
    console.trace()  if console.trace
    throw msg

that.shared_behavior = (name, func) ->
    validate_args.apply null, arguments
    alertAndThrow "The shared_behaviors has already been registered: '" + name + "' in " + current.description  if shared_behaviors[name]
    shared_behaviors[name] = ->
        func()

that.shared_scenario = (name, func) ->
    scenario name, func
    shared_behavior name, ->
        _then_it = then_it
        _and_ = and_
        that.then_it = to_skip = ->
            that.and_ = but_ = to_be_ignored = ->
    
        func()
        that.then_it = _then_it

that.it_behaves_as = (name, suite) ->
    f = shared_behaviors[name]
    alertAndThrow "A shared_behavior not found: " + name  unless f
    f()
    then_it "(kicker)", ->

mkand = (func, desc) ->
    (a, b) ->
        if typeof b == "function"
            func a, b
        else
            func desc, a

warnmsg = (msg, ex) ->
    if @jQuery
        $("body").prepend($("<li>").addClass("exception").text msg + " " + ex)
    else
        console.log msg, ex

that.given = (desc, func) ->
    validate_args.apply null, arguments
    current.suite._givens.push _given = ->
        try
            func()
        catch ex
            warnmsg "given '" + desc + "':", ex
            throw ex
  
    func.description = desc
    that.and_ = mkand(given, desc)

that.when_it = (desc, func) ->
    validate_args.apply null, arguments
    current.suite._when_its.push _then_its = ->
        try
            func()
        catch ex
            warnmsg "when_it '" + desc + "':", ex
            throw ex
  
    func.description = desc
    that.and_ = mkand(when_it, desc)
    that.but_ = and_

that.scenario = (desc, func) ->
    validate_args.apply null, arguments
    describe desc, ->
        _givens = []
        _when_its = _givens
        try
            current.suite = this
            current.suite._givens = _givens
            current.suite._when_its = _when_its
            current.description = desc
            func()
        finally
            current.suite = null

run_all = (funcs) ->
    while f = funcs.shift()
        f()

that.then_it = (desc, func) ->
    validate_args.apply null, arguments
    it desc, ->
        run_all @suite._givens
        run_all @suite._when_its
        try
            func()
        catch ex
            warnmsg "then_it '" + desc + "':", ex
    
    that.and_ = mkand(then_it, desc)
    that.but_ = and_

that.description = (desc, scope) ->
    validate_args.apply null, arguments
    describe desc, ->
        try
            current.description = desc
            scope()
        finally

that.narrative = (desc) ->

parameterize = (params, func) ->
    alertAndThrow "FIXME:"
    ->
        func params

that.xdescription = (desc) ->

that.xscenario = (desc) ->

that.xgiven = (desc) ->

that.xwhen_it = (desc) ->

that.xthen_it = (desc) ->

that.xand_ = (desc) ->

Number::shouldBe = (e) ->
    expect(Number(e)).toBe Number(this)

Boolean::shouldBeTruthy = ->
    expect(true).toBe Boolean(@valueOf())

Boolean::shouldBe = (e) ->
    expect(Boolean(e)).toBe Boolean(@valueOf())

String::shouldBe = (e) ->
    expect(String(e)).toBe String(this)

Number::shouldBeGreaterThan = (e) ->
    expect(Number(this)).toBeGreaterThan Number(e)

Number::shouldBeEqual = (e) ->
    expect(Number(e)).toEqual Number(this)

Number::shouldBeLessThan = (e) ->
    expect(Number(this)).toBeLessThan Number(e)

jasmine.story = 
    current: current
    shared_behaviors: shared_behaviors

$.fn.expectLengthIs = (len) ->
    @expect().lengthIs len

_expect = (that, f, p) ->
    switch typeof that[p]
        when "function"
            expect(f[p]).toBe that[p]()
        else
            expect(f[p]).toBe that[p]

$.fn.expect = (f) ->
    that = this
    if typeof f == "function"
        expect(f(that)).toEqual true
        return this
    else if typeof f == "object"
        for p of f
            continue if not f.hasOwnProperty(p)
            _expect that, f, p
        return this
    lengthIs: (len) ->
        expect(len).toBe that.length
        that
  
    existing: ->
        expect(that.length).toBeGreaterThan 0
        that
