//JUMLY v0.1.0-beta, 2011-2012 copyright(c), all rights reserved Tomotaka Sakuma. build Fri, 23 Nov 2012 02:21:31 GMT
(function() {
  var JUMLY, SCRIPT_TYPE_PATTERN, core, exported, jumly, _compilers, _evalHTMLScriptElement, _layouts, _runScripts, _to_type_string,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  jumly = function(arg, opts) {
    var mapJqToJy;
    mapJqToJy = function(arg) {
      var a, i, _i, _ref;
      if (typeof arg === "object" && !(typeof arg.length === "number" && typeof arg.data === "function")) {
        arg = $(arg);
      }
      for (i = _i = 0, _ref = arg.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        a = $(arg[i]).self();
        arg[i] = !a ? null : a;
      }
      return arg;
    };
    return mapJqToJy(arg);
  };

  $.jumly = jumly;

  $.fn.stereotype = function(n) {
    return this;
  };

  core = {};

  core._to_id = function(that) {
    if (that.constructor === jQuery) {
      return that.attr("id");
    }
    return that.toLowerCase().replace(/[^a-zA-Z0-9_]/g, "-");
  };

  core._to_ref = function(s) {
    if (s.match(/^[0-9].*/)) {
      return '_' + s;
    } else {
      return s.replace(/^[0-9]|-/g, '_');
    }
  };

  core.kindof = function(that) {
    var ctor, toName;
    if (that === null) {
      return 'Null';
    }
    if (that === void 0) {
      return 'Undefined';
    }
    ctor = that.constructor;
    toName = function(f) {
      if (__indexOf.call(f, 'name') >= 0) {
        return f.name;
      } else {
        return ('' + f).replace(/^function\s+([^\(]*)[\S\s]+$/im, '$1');
      }
    };
    if (typeof ctor === 'function') {
      return toName(ctor);
    } else {
      return tc;
    }
  };

  core._normalize = function(that) {
    var a, id, it, keys, mods, name, p;
    switch (core.kindof(that)) {
      case "String":
        return {
          id: core._to_id(that),
          name: that
        };
      case "Object":
        break;
      default:
        if (that && that.constructor === jQuery) {
          id = core._to_id(that);
          name = that.find(".name");
          if ((id != null) || (name.length > 0)) {
            return {
              id: id,
              name: (name.html() ? name.html() : void 0)
            };
          } else {
            return void 0;
          }
        }
        console.error("Cannot recognize kind:", that);
        throw new Error("Cannot recognize kind: '" + (core.kindof(that)) + "'");
    }
    keys = (function() {
      var _results;
      _results = [];
      for (p in that) {
        _results.push(p);
      }
      return _results;
    })();
    if (keys.length > 1) {
      return that;
    }
    id = keys[0];
    it = that[keys[0]];
    if (core.kindof(it) === "String") {
      return {
        id: id,
        name: it
      };
    }
    keys = (function() {
      var _results;
      _results = [];
      for (p in it) {
        _results.push(p);
      }
      return _results;
    })();
    if (keys.length > 1) {
      return $.extend({}, it, {
        id: core._to_id(id),
        name: id
      });
    }
    name = keys[0];
    mods = it[keys[0]];
    switch (core.kindof(mods)) {
      case "Object":
        return $.extend({
          id: id,
          name: name
        }, mods);
      case "Array":
      case "Function":
        a = {
          id: core._to_id(id),
          name: id
        };
        a[name] = mods;
        return a;
    }
  };

  core.env = {
    is_node: typeof module !== 'undefined' && typeof module.exports !== 'undefined'
  };

  JUMLY = {
    env: core.env
  };

  if (core.env.is_node) {
    global.JUMLY = JUMLY;
    module.exports = core;
  } else {
    window.JUMLY = JUMLY;
    exported = {
      core: core,
      "node-jquery": {},
      "./jasmine-matchers": {}
    };
    window.require = function(name) {
      if (name === void 0 || name === null) {
        throw new Error("" + name + " was not properly given");
      }
      if (!exported[name]) {
        console.warn("not found:", name);
      }
      return exported[name];
    };
    core.exports = function(func, name) {
      return exported[func.name || name] = func;
    };
  }

  SCRIPT_TYPE_PATTERN = /text\/jumly-(.*)-diagram|text\/jumly\+(.*)|application\/jumly\+(.*)/;

  _to_type_string = function(type) {
    var kind;
    if (!type.match(SCRIPT_TYPE_PATTERN)) {
      throw "Illegal type: " + type;
    }
    return kind = RegExp.$1 + RegExp.$2 + RegExp.$3;
  };

  _evalHTMLScriptElement = function(script) {
    var compiler, diag, kind, layout, type;
    script = $(script);
    type = script.attr("type");
    if (!type) {
      throw "Not found: type attribute in script";
    }
    kind = _to_type_string(type);
    compiler = _compilers["." + kind + "-diagram"];
    layout = _layouts["." + kind + "-diagram"];
    if (!compiler) {
      throw "Not found: compiler for '." + kind + "'";
    }
    if (!layout) {
      throw "Not found: layout for '." + kind + "'";
    }
    diag = compiler(script);
    diag.insertAfter(script);
    return layout(diag);
  };

  _compilers = {
    '.sequence-diagram': function(script) {
      var Builder;
      Builder = require("SequenceDiagramBuilder");
      return (new Builder).build(script.html());
    }
  };

  _layouts = {
    '.sequence-diagram': function(diagram) {
      var Layout;
      Layout = require("SequenceDiagramLayout");
      return (new Layout).layout(diagram);
    }
  };

  _runScripts = function() {
    var diagrams, s, script, scripts, _i, _len;
    if (_runScripts.done) {
      return null;
    }
    scripts = document.getElementsByTagName('script');
    diagrams = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = scripts.length; _i < _len; _i++) {
        s = scripts[_i];
        if (s.type.match(/text\/jumly+(.*)/)) {
          _results.push(s);
        }
      }
      return _results;
    })();
    for (_i = 0, _len = diagrams.length; _i < _len; _i++) {
      script = diagrams[_i];
      _evalHTMLScriptElement(script);
    }
    _runScripts.done = true;
    return null;
  };

  if (window.addEventListener) {
    window.addEventListener('DOMContentLoaded', _runScripts);
  } else {
    throw "window.addEventListener is not supported";
  }

}).call(this);

/*
This is capable to render followings:
- Synmetric figure
- Poly-line
*/


(function() {
  var Shape, shape_arrow, to_polar_from_cartesian, _line_to, _render_both, _render_dashed, _render_dashed2, _render_line, _render_line2, _render_normal;

  Shape = (function() {

    function Shape(ctxt) {
      this.ctxt = ctxt;
      this.pos = {
        left: 0,
        top: 0
      };
      this.memento = [];
    }

    return Shape;

  })();

  Shape.prototype.backtrack = function(depth) {
    var i, m;
    this.ctxt.save();
    this.ctxt.scale(1, -1);
    i = 0;
    while (m = this.memento.pop()) {
      m();
      i += 1;
      if (i >= depth) {
        break;
      }
    }
    this.ctxt.restore();
    return this;
  };

  Shape.prototype.line = function(dx, dy, b) {
    var _pos,
      _this = this;
    this.pos.left += dx;
    this.pos.top += dy;
    this.ctxt.lineTo(this.pos.left, this.pos.top);
    _pos = {
      left: this.pos.left,
      top: this.pos.top
    };
    this.memento.push(function(rx, ry) {
      return _this.ctxt.lineTo(_pos.left - dx, _pos.top - dy);
    });
    return this;
  };

  Shape.prototype.move = function(dx, dy) {
    var _pos,
      _this = this;
    this.pos.left += dx;
    this.pos.top += dy;
    this.ctxt.moveTo(this.pos.left, this.pos.top);
    _pos = {
      left: this.pos.left,
      top: this.pos.top
    };
    this.memento.push(function(rx, ry) {
      return _this.ctxt.moveTo(_pos.left - dx, _pos.top - dy);
    });
    return this;
  };

  Shape.prototype.lineTo = function(p, q) {
    var _pos,
      _this = this;
    _pos = {
      left: this.pos.left,
      top: this.pos.top
    };
    this.ctxt.lineTo(p, q);
    this.pos.left = p;
    this.pos.top = q;
    this.memento.push(function() {
      return _this.ctxt.lineTo(_pos.left, _pos.top);
    });
    return this;
  };

  Shape.prototype.moveTo = function(p, q) {
    var _pos,
      _this = this;
    _pos = {
      left: this.pos.left,
      top: this.pos.top
    };
    this.ctxt.moveTo(p, q);
    this.pos.left = p;
    this.pos.top = q;
    this.memento.push(function() {
      return _this.ctxt.moveTo(_pos.left, _pos.top);
    });
    return this;
  };

  /*
   * Convert to polar coordinate system from Cartesian coordinate system.
   * @return {
   *   gradients  :
   *   radius     :
   *   quadrants  : {x, y} x:1 or -1, y:1 or -1
   *   declination:
   *   offset     :
   * }
  */


  to_polar_from_cartesian = function(src, dst) {
    var dx, dy;
    dx = dst.left - src.left;
    dy = dst.top - src.top;
    return {
      offset: {
        left: src.left,
        top: src.top
      },
      radius: Math.sqrt(dx * dx + dy * dy),
      declination: Math.atan(dy / dx),
      quadrants: {
        x: dx !== 0 ? dx / Math.abs(dx) : 1,
        y: dy !== 0 ? dy / Math.abs(dy) : 1
      }
    };
  };

  _line_to = function(ctxt, src, dst, styles) {
    var i, p, pattern, plen, x, _i, _ref;
    if (!styles) {
      ctxt.moveTo(src.left, src.top);
      ctxt.lineTo(dst.left, dst.top);
      return;
    }
    styles = $.extend({
      pattern: [4, 4]
    }, styles);
    p = to_polar_from_cartesian(src, dst);
    ctxt.save();
    ctxt.translate(p.offset.left, p.offset.top);
    ctxt.rotate(p.declination);
    ctxt.scale(p.quadrants.x, p.quadrants.y);
    ctxt.moveTo(0, 0);
    pattern = styles.pattern;
    plen = pattern[0] + pattern[1];
    if (p.radius > 0) {
      for (i = _i = 0, _ref = p.radius - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = _i += plen) {
        x = i + pattern[0];
        if (p.radius - 1 <= x) {
          x = p.radius - 1;
        }
        ctxt.lineTo(x, 0);
        ctxt.moveTo(i + plen, 0);
      }
    }
    return ctxt.restore();
  };

  _render_both = function(ctxt, a, r, e, dt) {
    a.line(e.height, e.width + dt).line(0, -dt).line(r - e.height * 2, 0).line(0, dt).line(e.height, -(e.width + dt)).backtrack();
    return ctxt.closePath();
  };

  _render_line = function(ctxt, a, r, e, dt) {
    a.moveTo(0, 0).line(r, 0).line(-e.height, e.base).move(e.height, -e.base).line(-e.height, -e.base);
    return delete e.fillStyle;
  };

  _render_line2 = function(ctxt, a, r, e, dt) {
    return a.moveTo(0, 0).line(r - e.height, 0).line(0, e.base).line(e.height, -e.base).backtrack();
  };

  _render_dashed = function(ctxt, a, r, e, dt) {
    _line_to(ctxt, {
      left: 0,
      top: 0
    }, {
      left: r,
      top: 0
    }, {
      pattern: e.pattern
    });
    _line_to(ctxt, {
      left: r,
      top: 0
    }, {
      left: r - e.height,
      top: e.base
    });
    _line_to(ctxt, {
      left: r,
      top: 0
    }, {
      left: r - e.height,
      top: -e.base
    });
    return delete e.fillStyle;
  };

  _render_dashed2 = function(ctxt, a, r, e, dt) {
    _line_to(ctxt, {
      left: 0,
      top: 0
    }, {
      left: r - e.height,
      top: 0
    }, {
      pattern: e.pattern
    });
    return a.moveTo(r - e.height, 0).line(0, e.base).line(e.height, -e.base).line(-e.height, -e.base).line(0, e.base);
  };

  _render_normal = function(ctxt, a, r, e, dt) {
    a.moveTo(0, 0).line(0, e.width).line(r - e.height, 0).line(0, dt).line(e.height, -(e.width + dt)).backtrack();
    return ctxt.closePath();
  };

  /*
   * Draw an allow shape on a canvas.
   * This allow shape is defined by following style's 3 parameters.
   * @param styles: {
   *   width : Width of the edge for rectangle,
   *   base  : Length of the base edge,
   *   height: Height of triangle,
   * }
   * @param ctxt
   * @param src, dst
  */


  shape_arrow = function(ctxt, src, dst, styles) {
    var a, dt, e, p, r, _ref;
    p = to_polar_from_cartesian({
      left: src.x,
      top: src.y
    }, {
      left: dst.x,
      top: dst.y
    });
    r = p.radius;
    ctxt.save();
    ctxt.translate(src.x, src.y);
    ctxt.rotate(p.declination);
    ctxt.scale(p.quadrants.x, p.quadrants.y);
    e = $.extend({
      width: 20,
      base: 35,
      height: 50,
      pattern: [4, 4],
      shape: null
    }, styles);
    if ((_ref = e.lineWidth) == null) {
      e.lineWidth = 1.0;
    }
    $.extend(ctxt, e);
    ctxt.beginPath();
    if (e.tosrc) {
      ctxt.translate(r, 0);
      ctxt.rotate(Math.PI);
    }
    a = new Shape(ctxt);
    dt = e.base - e.width;
    switch (styles.shape) {
      case 'both':
        _render_both(ctxt, a, r, e, dt);
        break;
      case 'line':
        _render_line(ctxt, a, r, e, dt);
        break;
      case 'dashed':
        _render_dashed(ctxt, a, r, e, dt);
        break;
      case 'dashed2':
        _render_dashed2(ctxt, a, r, e, dt);
        break;
      case 'line2':
        _render_line2(ctxt, a, r, e, dt);
        break;
      default:
        _render_normal(ctxt, a, r, e, dt);
    }
    ctxt.stroke();
    if (e.fillStyle) {
      ctxt.fill();
    }
    return ctxt.restore();
  };

  $.g2d = {
    arrow: shape_arrow,
    path: Shape
  };

}).call(this);
(function() {
  var max, min, _fn;

  max = function(a, b) {
    return b - a;
  };

  min = function(a, b) {
    return a - b;
  };

  $.choose = function(nodes, ef, cmpf) {
    return $.map(nodes, ef).sort(cmpf)[0];
  };

  $.max = function(nodes, ef) {
    return $.choose(nodes, ef, max);
  };

  $.min = function(nodes, ef) {
    return $.choose(nodes, ef, min);
  };

  _fn = $.fn;

  _fn.choose = function(ef, cmpf) {
    return $.choose(this, ef, cmpf);
  };

  _fn.max = function(ef) {
    return $.max(this, ef);
  };

  _fn.min = function(ef) {
    return $.min(this, ef);
  };

  _fn.pickup2 = function(f0, f1, f2) {
    var prev,
      _this = this;
    if (this.length === 0) {
      return this;
    }
    f0(prev = $(this[0]));
    if (this.length === 1) {
      return this;
    }
    return this.slice(1).each(function(i, curr) {
      curr = $(curr);
      if ((f2 != null) && (i + 1 === _this.length - 1)) {
        f2(prev, curr, i + 1);
      } else {
        f1(prev, curr, i + 1);
      }
      return prev = curr;
    });
  };

  _fn.outerRight = function() {
    return this.offset().left + this.outerWidth();
  };

  _fn.right = function() {
    return this.offset().left + this.width() - 1;
  };

  _fn.outerBottom = function() {
    return this.offset().top + this.outerHeight() - 1;
  };

  _fn.mostLeftRight = function() {
    return {
      left: this.min(function(e) {
        return $(e).offset().left;
      }),
      right: this.max(function(e) {
        var t;
        t = $(e).offset().left + $(e).outerWidth();
        if (t - 1 < 0) {
          return 0;
        } else {
          return t - 1;
        }
      }),
      width: function() {
        if ((this.right != null) && (this.left != null)) {
          return this.right - this.left + 1;
        } else {
          return 0;
        }
      }
    };
  };

  _fn.mostTopBottom = function() {
    return {
      top: this.min(function(e) {
        return $(e).offset().top;
      }),
      bottom: this.max(function(e) {
        var t;
        t = $(e).offset().top + $(e).outerHeight();
        if (t - 1 < 0) {
          return 0;
        } else {
          return t - 1;
        }
      }),
      height: function() {
        if ((this.top != null) && (this.bottom != null)) {
          return this.bottom - this.top + 1;
        } else {
          return 0;
        }
      }
    };
  };

  _fn.cssAsInt = function(name) {
    var a;
    a = this.css(name);
    if (a) {
      return parseInt(a);
    } else {
      return 0;
    }
  };

  $.fn._d = function(p) {
    var a, e;
    e = this.find(p).data("_self");
    a = e.offset();
    a.right = a.left + e.width() - 1;
    a.bottom = a.top + e.height() - 1;
    a.width = e.width();
    a.center = a.left + (Math.round(e.width() / 2));
    a.middle = a.top + (Math.round(e.height() / 2));
    return a;
  };

  $.fold = function(list, init, func) {
    var e, l, _i, _len;
    l = init;
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      e = list[_i];
      l = func.apply(null, [l, e]);
    }
    return l;
  };

  $.reduce = function(list, func) {
    if (list.length === 0) {
      return void 0;
    }
    return $.fold(list.slice(1), list[0], func);
  };

}).call(this);
(function() {
  var HTMLElement, core;

  HTMLElement = (function() {

    function HTMLElement(args, f) {
      var cls, me, root;
      cls = HTMLElement.to_css_name(this.constructor.name);
      me = $.extend(this, root = $("<div>").addClass(cls));
      if (typeof f === "function") {
        f(me);
      }
      if (args) {
        me.find(".name").text(args);
      }
      me.data("_self", me);
    }

    HTMLElement.to_css_name = function(s) {
      return (s.match(/Diagram$/) ? s.replace(/Diagram$/, "-Diagram") : s.replace(/^[A-Z][a-z]+/, "")).toLowerCase();
    };

    return HTMLElement;

  })();

  HTMLElement.prototype.preferred_width = function() {
    return this.find("> *:eq(0)").outerWidth();
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = HTMLElement;
  } else {
    core.exports(HTMLElement);
  }

}).call(this);
(function() {
  var Diagram, HTMLElement, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  Diagram = (function(_super) {

    __extends(Diagram, _super);

    function Diagram() {
      Diagram.__super__.constructor.call(this);
      this.addClass("diagram");
    }

    return Diagram;

  })(HTMLElement);

  Diagram.prototype._var = function(varname, e) {
    return eval("" + varname + " = e");
  };

  core = require("core");

  Diagram.prototype._reg_by_ref = function(id, obj) {
    var exists, ref;
    exists = function(id, diag) {
      return $("#" + id).length > 0;
    };
    ref = core._to_ref(id);
    if (this[ref]) {
      throw new Error(("Already exists for '" + ref + "' in the ") + $.kindof(this));
    }
    if (exists(id, this)) {
      throw new Error("Element which has same ID(" + id + ") already exists in the document.");
    }
    this[ref] = obj;
    return ref;
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = Diagram;
  } else {
    core.exports(Diagram);
  }

}).call(this);
(function() {
  var CoffeeScript, DiagramBuilder, core;

  DiagramBuilder = (function() {

    function DiagramBuilder() {}

    return DiagramBuilder;

  })();

  core = require("core");

  if (core.env.is_node) {
    CoffeeScript = require("coffee-script");
  } else {
    CoffeeScript = window.CoffeeScript;
  }

  DiagramBuilder.prototype.build = function(script) {
    (function() {
      return eval(CoffeeScript.compile(script));
    }).apply(this, []);
    return this._diagram;
  };

  DiagramBuilder.prototype.diagram = function() {
    return this._diagram;
  };

  if (core.env.is_node) {
    module.exports = DiagramBuilder;
  } else {
    core.exports(DiagramBuilder);
  }

}).call(this);
(function() {
  var DiagramLayout, core;

  DiagramLayout = (function() {

    function DiagramLayout() {}

    return DiagramLayout;

  })();

  DiagramLayout.prototype.layout = function(diagram) {
    this.diagram = diagram;
    this.prefs = diagram.preferences();
    return typeof this._layout_ === "function" ? this._layout_() : void 0;
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = DiagramLayout;
  } else {
    core.exports(DiagramLayout);
  }

}).call(this);
(function() {
  var HTMLElement, SequenceLifeline, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  SequenceLifeline = (function(_super) {

    __extends(SequenceLifeline, _super);

    function SequenceLifeline(_object) {
      var self;
      this._object = _object;
      self = this;
      SequenceLifeline.__super__.constructor.call(this, null, function(me) {
        return me.append($("<div>").addClass("line")).width(self._object.width());
      });
    }

    return SequenceLifeline;

  })(HTMLElement);

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceLifeline;
  } else {
    core.exports(SequenceLifeline);
  }

}).call(this);
(function() {
  var HTMLElement, MESSAGE_STYLE, STEREOTYPE_STYLES, SequenceMessage, core, _determine_primary_stereotype,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  SequenceMessage = (function(_super) {

    __extends(SequenceMessage, _super);

    function SequenceMessage(_iact, _actee) {
      this._iact = _iact;
      this._actee = _actee;
      SequenceMessage.__super__.constructor.call(this, null, function(me) {
        return me.append($("<canvas>").addClass("arrow")).append($("<div>").addClass("name"));
      });
    }

    return SequenceMessage;

  })(HTMLElement);

  SequenceMessage.prototype._lineToNextOccurr = function(canvas) {
    var dstll, srcll;
    if (false) {
      console.log("FIXME: to avoid runtime error.");
      ({
        src: {
          x: 0,
          y: 0
        },
        dst: {
          x: 400,
          y: 0
        }
      });
    }
    srcll = this._srcOccurr();
    dstll = this._dstOccurr();
    return this._toLine(srcll, dstll, canvas);
  };

  SequenceMessage.prototype._toLine = function(src, dst, canvas) {
    var e, y;
    e = !this.parent().hasClass("lost") && this.isTowardLeft() ? {
      src: {
        x: src.offset().left - this.offset().left
      },
      dst: {
        x: dst.outerWidth()
      }
    } : {
      src: {
        x: src.outerWidth()
      },
      dst: {
        x: dst.offset().left - src.offset().left
      }
    };
    y = canvas.outerHeight() / 2;
    e.src.y = y;
    e.dst.y = y;
    return e;
  };

  SequenceMessage.prototype._srcOccurr = function() {
    return this.parents(".occurrence:eq(0)").self();
  };

  SequenceMessage.prototype._dstOccurr = function() {
    return (this.hasClass("return") ? this.prev(".occurrence") : $("~ .occurrence", this)).self();
  };

  SequenceMessage.prototype._prefferedCanvas = function() {
    return this.find("canvas:eq(0)").attr({
      width: this.width(),
      height: this.height()
    }).css({
      width: this.width(),
      height: this.height()
    });
  };

  SequenceMessage.prototype._toCreateLine = function(canvas) {
    var e, src;
    e = this._toLine(this._srcOccurr(), this._dstOccurr()._actor, canvas);
    if (this.isTowardLeft()) {
      src = this._srcOccurr();
      e.dst.x = src._actor.outerRight() - src.offset().left;
    }
    return e;
  };

  SequenceMessage.prototype._findOccurr = function(actee) {
    var occurr,
      _this = this;
    occurr = null;
    this.parents(".occurrence").each(function(i, e) {
      e = $(e).data("_self");
      if (e._actor === actee) {
        return occurr = e;
      }
    });
    return occurr;
  };

  MESSAGE_STYLE = {
    width: 1,
    base: 6,
    height: 10,
    lineWidth: 1.5,
    shape: "line2",
    pattern: [8, 8],
    strokeStyle: 'gray',
    fillStyle: 'gray'
  };

  STEREOTYPE_STYLES = {
    create: {
      shape: "dashed"
    },
    asynchronous: {
      shape: "line"
    },
    synchronous: {
      shape: "line2",
      fillStyle: 'gray'
    },
    destroy: {
      shape: "line2",
      fillStyle: 'gray'
    }
  };

  _determine_primary_stereotype = function(jqnode) {
    var e, _i, _len, _ref;
    _ref = ["create", "asynchronous", "synchronous", "destroy"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      if (jqnode.hasClass(e)) {
        return e;
      }
    }
  };

  SequenceMessage.prototype.repaint = function(style) {
    var a, arrow, canvas, ctxt, gap, line, llw, newdst, newsrc, p, rcx, rey, shape;
    shape = STEREOTYPE_STYLES[_determine_primary_stereotype(this)];
    arrow = jQuery.extend({}, MESSAGE_STYLE, style, shape);
    canvas = this._current_canvas = this._prefferedCanvas();
    if (style != null ? style.inherit : void 0) {
      p = this.parents(".occurrence:eq(0)");
      arrow.fillStyle = p.css("background-color");
      arrow.strokeStyle = p.css("border-top-color");
      (p.css("box-shadow")).match(/(rgba\(.*\)) ([0-9]+)px ([0-9]+)px ([0-9]+)px ([0-9]+)px/);
      arrow.shadowColor = RegExp.$1;
      arrow.shadowOffsetX = RegExp.$2;
      arrow.shadowOffsetY = RegExp.$3;
      arrow.shadowBlur = RegExp.$4;
    }
    if (arrow.self) {
      ctxt = canvas[0].getContext('2d');
      gap = 2;
      rcx = this.width() - (gap + 4);
      rey = this.height() - (arrow.height / 2 + 4);
      llw = this._dstOccurr().outerWidth();
      $.g2d.arrow(ctxt, {
        x: rcx,
        y: rey
      }, {
        x: llw + gap,
        y: rey
      }, arrow);
      arrow.base = 0;
      $.g2d.arrow(ctxt, {
        x: llw / 2 + gap,
        y: gap
      }, {
        x: rcx,
        y: gap
      }, arrow);
      $.g2d.arrow(ctxt, {
        x: rcx,
        y: gap
      }, {
        x: rcx,
        y: rey
      }, arrow);
      return this;
    }
    if (this.hasClass("create")) {
      line = this._toCreateLine(canvas);
    } else if (this._actee) {
      newsrc = this._findOccurr(this._actee);
      newdst = this._dstOccurr();
      line = this._toLine(newsrc, newdst, canvas);
    } else {
      line = this._lineToNextOccurr(canvas);
    }
    if (arrow.reverse) {
      a = line.src;
      line.src = line.dst;
      line.dst = a;
      arrow.shape = 'dashed';
    }
    jQuery.g2d.arrow(canvas[0].getContext('2d'), line.src, line.dst, arrow);
    return this;
  };

  SequenceMessage.prototype.isToward = function(dir) {
    var actee, actor;
    actor = this._iact._actor._actor;
    actee = this._iact._actee._actor;
    if ("right" === dir) {
      return actor.isLeftAt(actee);
    } else if ("left" === dir) {
      return actor.isRightAt(actee);
    }
  };

  SequenceMessage.prototype.isTowardRight = function() {
    return this.isToward("right");
  };

  SequenceMessage.prototype.isTowardLeft = function() {
    return this.isToward("left");
  };

  SequenceMessage.prototype._to_be_creation = function() {
    var dst, line_width, shift_downward, src;
    src = this._srcOccurr();
    dst = this._dstOccurr();
    line_width = function(msg) {
      var l;
      l = msg._toLine(src, dst._actor, msg);
      return Math.abs(l.src.x - l.dst.x);
    };
    shift_downward = function(msg) {
      var dy, iact, mt, obj;
      obj = dst._actor;
      obj.offset({
        top: msg.offset().top - obj.height() / 3
      });
      mt = parseInt(dst.css("margin-top"));
      dst.offset({
        top: obj.outerBottom() + mt
      });
      iact = msg.parents(".interaction:eq(0)");
      dy = iact.outerBottom() - dst.outerBottom() - mt;
      return iact.css("margin-bottom", Math.abs(dy));
    };
    this.outerWidth((line_width(this)) + src.outerWidth() - 1);
    return shift_downward(this);
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceMessage;
  } else {
    core.exports(SequenceMessage);
  }

}).call(this);
(function() {
  var HTMLElement, SequenceInteraction, SequenceMessage, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  SequenceInteraction = (function(_super) {

    __extends(SequenceInteraction, _super);

    function SequenceInteraction(_actor, _actee) {
      var self;
      this._actor = _actor;
      this._actee = _actee;
      self = this;
      SequenceInteraction.__super__.constructor.call(this, null, function(me) {
        return me.append(new SequenceMessage(self));
      });
    }

    return SequenceInteraction;

  })(HTMLElement);

  SequenceInteraction.prototype.interact = function(obj) {
    return this.awayfrom().interact(obj);
  };

  SequenceInteraction.prototype.forward = function(obj) {
    return this.toward();
  };

  SequenceInteraction.prototype.to = function(func) {
    var occurrs, tee, tor;
    occurrs = this.gives(".occurrence");
    tee = occurrs.as(".actee");
    tor = occurrs.as(".actor");
    return func(tee, tor);
  };

  SequenceInteraction.prototype.forwardTo = function() {
    return this.gives(".occurrence").as(".actee");
  };

  SequenceInteraction.prototype.backwardTo = function() {
    return this.gives(".occurrence").as(".actor");
  };

  SequenceInteraction.prototype.toward = function() {
    return this.forwardTo();
  };

  SequenceInteraction.prototype.awayfrom = function(obj) {
    var e, _i, _len, _ref;
    if (!obj) {
      return this.backwardTo();
    }
    _ref = this.parents(".occurrence").not(".activated");
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      e = $(e).self();
      if ((e != null ? e.gives(".object") : void 0) === obj) {
        return e;
      }
    }
    return obj.activate();
  };

  SequenceInteraction.prototype._compose_ = function() {
    var actee, dst, errmsg, msg, newdst, rmsg, src, that, w, x;
    that = this;
    src = this._actor;
    dst = this._actee;
    msg = that.find("> .message").data("_self");
    if (this.isToSelf()) {
      this._buildSelfInvocation(src, dst, msg);
      return;
    }
    w = src.offset().left - (dst.offset().left + $(".occurrence:eq(0)", that).width());
    if (this.hasClass("lost")) {
      msg.height(dst.outerHeight());
    } else if (msg.isTowardLeft()) {
      w = dst.offset().left - (src.offset().left + $(".occurrence:eq(0)", that).width());
    }
    msg.width(Math.abs(w)).offset({
      left: Math.min(src.offset().left, dst.offset().left)
    }).repaint();
    rmsg = $("> .message.return:last", that).data("_self");
    if (rmsg) {
      x = msg.offset().left;
      actee = rmsg._actee;
      if (actee) {
        newdst = rmsg._findOccurr(actee);
        if (!newdst) {
          errmsg = "SemanticError: it wasn't able to reply back to '" + (actee.find('.name').text()) + "' which is missing";
          throw new Error(errmsg);
        }
        w = dst.offset().left - newdst.offset().left;
        x = Math.min(dst.offset().left, newdst.offset().left);
      }
      return rmsg.width(Math.abs(w)).offset({
        left: x
      }).repaint({
        reverse: true
      });
    }
  };

  SequenceInteraction.prototype._buildSelfInvocation = function(a, b, msg) {
    var arrow, dx, dy, w;
    w = this.find(".occurrence:eq(0)").outerWidth();
    dx = w * 2;
    dy = w * 1;
    b.css({
      top: 0 + dy
    });
    this.css({
      "padding-bottom": dy
    });
    msg.css({
      top: 0
    }).width(b.width() + dx).height(b.offset().top - msg.offset().top + dy + w / 8).offset({
      left: b.offset().left
    });
    msg.repaint({
      self: true
    });
    arrow = msg.find(".arrow");
    return msg.find(".name").offset({
      left: arrow.offset().left + arrow.outerWidth(),
      top: arrow.offset().top
    });
  };

  SequenceMessage = require("SequenceMessage");

  SequenceInteraction.prototype.reply = function(p) {
    var a;
    this.addClass("reply");
    a = new SequenceMessage(this, p != null ? p[".actee"] : void 0).addClass("return").insertAfter(this.children(".occurrence:eq(0)"));
    $(a).find(".name:eq(0)").text($(p).find(".name:eq(0)").text());
    return this;
  };

  SequenceInteraction.prototype.fragment = function(attrs, opts) {
    var SequenceFragment, frag;
    SequenceFragment = require("SequenceFragment");
    frag = new SequenceFragment();
    return frag.enclose(this);
  };

  SequenceInteraction.prototype.isToSelf = function() {
    var a, b;
    a = this._actor;
    b = this._actee;
    if (!(a && b)) {
      return false;
    }
    return a._actor === b._actor;
  };

  SequenceInteraction.prototype.is_to_itself = function() {
    return this.isToSelf();
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceInteraction;
  } else {
    core.exports(SequenceInteraction);
  }

}).call(this);
(function() {
  var HTMLElement, SequenceInteraction, SequenceOccurrence, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  SequenceOccurrence = (function(_super) {

    __extends(SequenceOccurrence, _super);

    function SequenceOccurrence(_actor) {
      this._actor = _actor;
      SequenceOccurrence.__super__.constructor.call(this);
    }

    return SequenceOccurrence;

  })(HTMLElement);

  core = require("core");

  SequenceInteraction = require("SequenceInteraction");

  SequenceOccurrence.prototype.interact = function(actor, acts) {
    var SequenceFragment, alt, iact, occurr;
    if ((acts != null ? acts.stereotype : void 0) === ".lost") {
      occurr = new SequenceOccurrence().addClass("icon");
      iact = new SequenceInteraction(this, occurr);
      iact.addClass("lost");
    } else if ((acts != null ? acts.stereotype : void 0) === ".destroy") {

    } else if ((actor != null ? actor.stereotype : void 0) === ".alt") {
      SequenceFragment = require("SequenceFragment");
      alt = new SequenceFragment("alt");
      alt.alter(this, acts);
      return this;
    } else {
      occurr = new SequenceOccurrence(actor);
      iact = new SequenceInteraction(this, occurr);
    }
    iact.append(occurr).appendTo(this);
    return iact;
  };

  SequenceOccurrence.prototype.create = function(objsrc) {
    var SequenceObject, iact, obj;
    SequenceObject = require("SequenceObject");
    obj = new SequenceObject(objsrc.name).addClass("created-by");
    this._actor.parent().append(obj);
    return iact = (this.interact(obj)).find(".message").addClass("create").end();
  };

  SequenceOccurrence.prototype._move_horizontally = function() {
    var left;
    if (this.parent().hasClass("lost")) {
      offset({
        left: this.parents(".diagram").find(".object").mostLeftRight().right
      });
      return this;
    }
    if (!this.is_on_another()) {
      left = this._actor.offset().left + (this._actor.preferred_width() - this.width()) / 2;
    } else {
      left = this._parent_occurr().offset().left;
    }
    left += this.width() * this._shift_to_parent() / 2;
    return this.offset({
      left: left
    });
  };

  SequenceOccurrence.prototype.is_on_another = function() {
    return !(this._parent_occurr() === null);
  };

  SequenceOccurrence.prototype._parent_occurr = function() {
    var i, occurrs, _i, _ref;
    occurrs = this.parents(".occurrence");
    if (occurrs.length === 0) {
      return null;
    }
    for (i = _i = 0, _ref = occurrs.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
      if (this._actor === $(occurrs[i]).data("_self")._actor) {
        return $(occurrs[i]).data("_self");
      }
    }
    return null;
  };

  SequenceOccurrence.prototype._shift_to_parent = function() {
    var a;
    if (!this.is_on_another()) {
      return 0;
    }
    a = this.parent().find(".message:eq(0)").data("_self");
    if (a === void 0) {
      return 0;
    }
    if (a.isTowardRight()) {
      return -1;
    }
    if (a.isTowardLeft()) {
      return 1;
    }
    return 1;
  };

  SequenceOccurrence.prototype.preceding = function(obj) {
    var f;
    f = function(ll) {
      var a;
      a = jumly(ll.parents(".occurrence:eq(0)"))[0];
      if (!a) {
        return null;
      }
      if (a.gives(".object") === obj) {
        return a;
      }
      return f(a);
    };
    return f(this);
  };

  SequenceOccurrence.prototype.destroy = function(actee) {
    var occur;
    occur = this.interact(actee).stereotype("destroy").data("_self")._actee;
    if (occur.is_on_another()) {
      occur = occur._parent_occurr();
    }
    $("<div>").addClass("stop").append($("<div>").addClass("icon").addClass("square").addClass("cross")).insertAfter(occur);
    return occur;
  };

  if (core.env.is_node) {
    module.exports = SequenceOccurrence;
  } else {
    core.exports(SequenceOccurrence);
  }

}).call(this);
(function() {
  var HTMLElement, SequenceInteraction, SequenceObject, SequenceOccurrence, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  SequenceObject = (function(_super) {

    __extends(SequenceObject, _super);

    function SequenceObject(args) {
      SequenceObject.__super__.constructor.call(this, args, function(me) {
        return me.append($("<div>").addClass("name"));
      });
    }

    return SequenceObject;

  })(HTMLElement);

  core = require("core");

  SequenceOccurrence = require("SequenceOccurrence");

  SequenceInteraction = require("SequenceInteraction");

  SequenceObject.prototype.activate = function() {
    var iact, occurr;
    occurr = new SequenceOccurrence(this);
    iact = new SequenceInteraction(null, occurr);
    iact.addClass("activated");
    iact.find(".message").remove();
    iact.append(occurr);
    this.parent().append(iact);
    return occurr;
  };

  SequenceObject.prototype.isLeftAt = function(a) {
    return this.offset().left < a.offset().left;
  };

  SequenceObject.prototype.isRightAt = function(a) {
    return (a.offset().left + a.width()) < this.offset().left;
  };

  SequenceObject.prototype.iconify = function(fixture, styles) {
    var canvas, container, render, size, _ref,
      _this = this;
    if (typeof fixture !== "function") {
      fixture = $.jumly.icon["." + fixture] || $.jumly.icon[".actor"];
    }
    canvas = $("<canvas>").addClass("icon");
    container = $("<div>").addClass("icon-container");
    this.addClass("iconified").prepend(container.append(canvas));
    _ref = fixture(canvas[0], styles), size = _ref.size, styles = _ref.styles;
    container.css({
      height: size.height
    });
    render = function() {
      var name;
      name = _this.find(".name");
      styles.fillStyle = name.css("background-color");
      styles.strokeStyle = name.css("border-top-color");
      return fixture(canvas[0], styles);
    };
    this.renderIcon = function() {
      return render();
    };
    return this;
  };

  SequenceObject.prototype.lost = function() {
    return this.activate().interact(null, {
      stereotype: ".lost"
    });
  };

  if (core.env.is_node) {
    module.exports = SequenceObject;
  } else {
    core.exports(SequenceObject);
  }

}).call(this);

/*
<div class="class icon">
  <span class="stereotype">abstract</span>
  <span class="name">UMLObject</span>
  <ul class="attrs">
    <li>name</li>
    <li>stereotypes</li>
  </ul>
  <ul class="methods">
    <li>activate</li>
    <li>isLeftAt(a)</li>
    <li>isRightAt(a)</li>
    <li>iconify(fixture, styles)</li>
    <li>lost</li>
  </ul>
</div>
*/


(function() {
  var Class, HTMLElement, def,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  Class = (function(_super) {

    __extends(Class, _super);

    function Class() {
      return Class.__super__.constructor.apply(this, arguments);
    }

    return Class;

  })(HTMLElement);

  Class.prototype._build_ = function(div) {
    var icon;
    icon = $("<div>").addClass("icon").append($("<div>").addClass("stereotype")).append($("<div>").addClass("name")).append($("<ul>").addClass("attrs")).append($("<ul>").addClass("methods"));
    return div.addClass("object").append(icon);
  };

  def = function() {};

  def(".class", Class);

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = Class;
  } else {
    require("core").Class = Class;
  }

}).call(this);
(function() {
  var ClassDiagram, Diagram, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Diagram = require("Diagram");

  ClassDiagram = (function(_super) {

    __extends(ClassDiagram, _super);

    function ClassDiagram() {
      return ClassDiagram.__super__.constructor.apply(this, arguments);
    }

    return ClassDiagram;

  })(Diagram);

  ClassDiagram.prototype.member = function(kind, clz, normval) {
    var holder;
    holder = clz.find("." + kind + "s");
    return $(normval["" + kind + "s"]).each(function(i, e) {
      var id;
      id = "" + normval.id + "-" + kind + "-" + e;
      if (holder.find("." + e).length > 0) {
        throw new Error("Already exists " + e);
      }
      return holder.append($("<li>").addClass(e).attr("id", id).html(e));
    });
  };

  ClassDiagram.prototype.declare = function(normval) {
    var clz, kind, ref, _i, _len, _ref;
    clz = $.jumly(".class", normval);
    if (normval.stereotype) {
      clz.find(".stereotype").html(normval.stereotype);
    } else {
      clz.find(".stereotype").hide();
    }
    _ref = ["attr", "method"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      kind = _ref[_i];
      this.member(kind, clz, normval);
    }
    ref = this._regByRef_(normval.id, clz);
    eval("" + ref + " = clz");
    return this.append(clz);
  };

  ClassDiagram.prototype.preferredWidth = function() {
    return this.find(".class .icon").mostLeftRight().width() + 16;
  };

  ClassDiagram.prototype.preferredHeight = function() {
    return this.find(".class .icon").mostTopBottom().height();
  };

  ClassDiagram.prototype.compose = function() {
    this.find(".class .icon").each(function(i, e) {
      e = $(e);
      if (e.width() > e.height()) {
        return null;
      }
      return e.width(e.height() * (1 + Math.sqrt(2)) / 2);
    });
    this.width(this.preferredWidth());
    this.height(this.preferredHeight());
    return this;
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = ClassDiagram;
  } else {
    core.exports(ClassDiagram);
  }

}).call(this);
(function() {
  var ClassDiagramBuilder, DSL, DiagramBuilder,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  DiagramBuilder = require("DiagramBuilder");

  ClassDiagramBuilder = (function(_super) {

    __extends(ClassDiagramBuilder, _super);

    function ClassDiagramBuilder(diagram) {
      this.diagram = diagram;
    }

    return ClassDiagramBuilder;

  })(DiagramBuilder);

  ClassDiagramBuilder.prototype.def = function(props) {
    return this.diagram.declare(Identity.normalize(props));
  };

  ClassDiagramBuilder.prototype.start = function(acts) {
    return acts.apply(this, []);
  };

  DSL = function() {};

  DSL({
    type: ".class-diagram",
    compileScript: function(script) {
      var b;
      b = new ClassDiagramBuilder;
      return b.build(script.html());
    }
  });

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = ClassDiagramBuilder;
  } else {
    require("core").ClassDiagramBuilder = ClassDiagramBuilder;
  }

}).call(this);
(function() {
  var HorizontalSpacing, core, root;

  HorizontalSpacing = (function() {

    function HorizontalSpacing(a, b) {
      $.extend(this, $("<span>"));
      this.data("left", a);
      this.data("right", b);
      this.addClass("horizontal");
      this.addClass("spacing");
    }

    return HorizontalSpacing;

  })();

  HorizontalSpacing.prototype.apply = function() {
    var a, b;
    a = this.data("left").data("_self");
    b = this.data("right").data("_self");
    a.after(this);
    this.offset({
      left: a.offset().left + a.preferred_width(),
      top: a.offset().top
    });
    return b.offset({
      left: this.offset().left + this.outerWidth()
    });
  };

  root = {
    HorizontalSpacing: HorizontalSpacing
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = root;
  } else {
    (require("core")).exports(root, "HTMLElementLayout");
  }

}).call(this);
(function() {
  var Position, PositionLeft, PositionLeftRight, PositionRightLeft, PositionTop, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  Position = (function() {

    function Position(attrs) {
      this.attrs = attrs;
      this.div = $("<div>").addClass(this.attrs.css).css({
        position: "absolute"
      });
    }

    return Position;

  })();

  Position.prototype._coordinate = function(target) {
    if (this.attrs.coordinate) {
      return this.attrs.coordinate.append(this.div);
    } else {
      return target.after(this.div);
    }
  };

  PositionRightLeft = (function(_super) {

    __extends(PositionRightLeft, _super);

    function PositionRightLeft() {
      return PositionRightLeft.__super__.constructor.apply(this, arguments);
    }

    return PositionRightLeft;

  })(Position);

  PositionLeftRight = (function(_super) {

    __extends(PositionLeftRight, _super);

    function PositionLeftRight() {
      return PositionLeftRight.__super__.constructor.apply(this, arguments);
    }

    return PositionLeftRight;

  })(Position);

  PositionLeft = (function(_super) {

    __extends(PositionLeft, _super);

    function PositionLeft() {
      return PositionLeft.__super__.constructor.apply(this, arguments);
    }

    return PositionLeft;

  })(Position);

  PositionTop = (function(_super) {

    __extends(PositionTop, _super);

    function PositionTop() {
      return PositionTop.__super__.constructor.apply(this, arguments);
    }

    return PositionTop;

  })(Position);

  PositionRightLeft.prototype.apply = function() {
    var src;
    src = this.attrs.src;
    this._coordinate(src);
    this.div.offset({
      left: src.offset().left + src.outerWidth()
    });
    return this.attrs.dst.offset({
      left: this.div.offset().left + this.div.outerWidth()
    });
  };

  PositionLeftRight.prototype.apply = function() {
    var dst, src;
    src = this.attrs.src;
    dst = this.attrs.dst;
    this._coordinate(src);
    this.div.offset({
      left: src.offset().left - this.div.outerWidth()
    });
    return this.attrs.dst.offset({
      left: this.div.offset().left - this.attrs.dst.outerWidth()
    });
  };

  PositionLeft.prototype.apply = function() {
    var dst;
    dst = this.attrs.dst;
    this._coordinate(dst);
    return this.attrs.dst.offset({
      left: this.div.offset().left + this.div.outerWidth()
    });
  };

  PositionTop.prototype.apply = function() {
    var dst;
    dst = this.attrs.dst;
    this._coordinate(dst);
    return this.attrs.dst.offset({
      top: this.div.offset().top + this.div.outerHeight()
    });
  };

  Position.RightLeft = PositionRightLeft;

  Position.LeftRight = PositionLeftRight;

  Position.Left = PositionLeft;

  Position.Top = PositionTop;

  core = require("core");

  if (core.env.is_node) {
    module.exports = Position;
  } else {
    core.exports(Position);
  }

}).call(this);
(function() {
  var HTMLElement, MESSAGE_STYLE, Relationship, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  Relationship = (function(_super) {

    __extends(Relationship, _super);

    function Relationship() {
      return Relationship.__super__.constructor.apply(this, arguments);
    }

    return Relationship;

  })(HTMLElement);

  Relationship.prototype._build_ = function(div, opts) {
    this.src = opts.src;
    this.dst = opts.dst;
    return div.append($("<canvas>").addClass("icon")).append($("<div>").addClass("name"));
  };

  MESSAGE_STYLE = {
    width: 1,
    base: 6,
    height: 10,
    lineWidth: 1.5,
    shape: "dashed",
    pattern: [8, 8],
    strokeStyle: 'gray',
    fillStyle: 'gray',
    lineJoin: 'round'
  };

  Math.sign = function(x) {
    if (x === 0) {
      return 0;
    } else if (x > 0) {
      return 1;
    }
    return -1;
  };

  Relationship.prototype.render = function() {
    var aa, bb, cc, cr, ctxt, dd, dsticon, expand, margin, margin_left, margin_top, p, pt, q, r, rect, s, srcicon, style, t;
    margin_left = $("body").cssAsInt("margin-left");
    margin_top = $("body").cssAsInt("margin-top");
    pt = function(obj) {
      var dh, dv, p, s;
      s = obj.offset();
      dh = 0 * (obj.cssAsInt("margin-left")) - margin_left;
      dv = 0 * obj.css("margin-top").toInt() - margin_top;
      return p = {
        left: s.left + obj.outerWidth() / 2 + dh,
        top: s.top + obj.outerHeight() / 2 + dv
      };
    };
    rect = function(p, q) {
      var a, b, h, hs, l, r, vs, w;
      a = {
        left: Math.min(p.left, q.left),
        top: Math.min(p.top, q.top)
      };
      b = {
        left: Math.max(p.left, q.left),
        top: Math.max(p.top, q.top)
      };
      w = b.left - a.left + 1;
      h = b.top - a.top + 1;
      hs = Math.sign(q.left - p.left);
      vs = Math.sign(q.top - p.top);
      l = Math.sqrt(w * w + h * h);
      return r = {
        left: a.left,
        top: a.top,
        width: w,
        height: h,
        hsign: hs,
        vsign: vs,
        hunit: hs * w / l,
        vunit: vs * h / l
      };
    };
    expand = function(rect, val) {
      var d, r;
      if (typeof val === "number") {
        return expand(rect, {
          left: val,
          top: val,
          right: val,
          bottom: val
        });
      }
      r = $.extend({}, rect);
      for (d in val) {
        switch (d) {
          case "left":
            r.left -= val[d];
            r.width += val[d];
            break;
          case "top":
            r.top -= val[d];
            r.height += val[d];
            break;
          case "right":
            r.width += val[d];
            break;
          case "bottom":
            r.height += val[d];
        }
      }
      return r;
    };
    srcicon = this.src.find(".icon");
    dsticon = this.dst.find(".icon");
    p = pt(srcicon);
    q = pt(dsticon);
    r = rect(p, q);
    cr = 2;
    aa = r.hunit * dsticon.outerWidth() / cr;
    bb = r.vunit * dsticon.outerHeight() / cr;
    cc = r.hunit * srcicon.outerWidth() / cr;
    dd = r.vunit * srcicon.outerHeight() / cr;
    s = {
      x: p.left - r.left + cc,
      y: p.top - r.top + dd
    };
    t = {
      x: q.left - r.left - aa,
      y: q.top - r.top - bb
    };
    margin = 4;
    r = expand(r, margin);
    this.width(r.width);
    this.height(r.height);
    this.offset({
      left: r.left,
      top: r.top
    });
    ctxt = this.find("canvas").css({
      width: r.width,
      height: r.height
    }).attr({
      width: r.width,
      height: r.height
    })[0].getContext("2d");
    ctxt.save();
    ctxt.translate(margin, margin);
    style = $.extend({}, MESSAGE_STYLE, {
      pattern: [4, 4],
      shape: 'line'
    });
    if (this.hasClass("extend")) {
      style = $.extend(style, {
        shape: 'dashed'
      });
    }
    $.g2d.arrow(ctxt, s, t, style);
    return ctxt.restore();
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = Relationship;
  } else {
    core.exports(Relationship);
  }

}).call(this);
(function() {
  var Diagram, HTMLElement, SequenceDiagram, core, jumly, prefs_,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  jumly = $.jumly;

  jQuery.fn.swallow = function(_, f) {
    f = f || jQuery.fn.append;
    if (_.length === 1) {
      if (_.index() === 0) {
        _.parent().prepend(this);
      } else {
        this.insertAfter(_.prev());
      }
    } else {
      if (_.index() === 0) {
        this.prependTo($(_[0]).parent());
      } else {
        this.insertBefore(_[0]);
      }
    }
    this.append(_.detach());
    return this;
  };

  Diagram = require("Diagram");

  SequenceDiagram = (function(_super) {

    __extends(SequenceDiagram, _super);

    function SequenceDiagram() {
      SequenceDiagram.__super__.constructor.call(this);
    }

    return SequenceDiagram;

  })(Diagram);

  SequenceDiagram.prototype.gives = function(query) {
    var e, f;
    e = this.find(query);
    f = jumly.lang._of(e, query);
    return {
      of: f
    };
  };

  prefs_ = {
    WIDTH: null,
    HEIGHT: 50
  };

  SequenceDiagram.prototype.$ = function(sel) {
    return jumly($(sel, this));
  };

  SequenceDiagram.prototype.$0 = function(typesel) {
    return this.$(typesel)[0];
  };

  SequenceDiagram.prototype.preferences = function(a, b) {
    var prefs, r, width;
    prefs = {};
    width = function() {
      var left, objs, right;
      objs = $(".object", this);
      left = objs.min(function(e) {
        return $(e).position().left;
      }) - this.position().left;
      right = objs.max(function(e) {
        return $(e).position().left + $(e).outerWidth();
      }) - this.position().left;
      return left + (right - left) + left;
    };
    if ((!b && typeof a === "string") || (!a && !b)) {
      r = $.extend({}, prefs, prefs_);
      r.WIDTH = width.apply(this);
      return r;
    }
    return $.extend(prefs, a);
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceDiagram;
  } else {
    core.exports(SequenceDiagram);
  }

}).call(this);
(function() {
  var DiagramBuilder, SequenceDiagram, SequenceDiagramBuilder, SequenceObject, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  DiagramBuilder = require("DiagramBuilder");

  SequenceDiagramBuilder = (function(_super) {

    __extends(SequenceDiagramBuilder, _super);

    function SequenceDiagramBuilder(_diagram, _occurr) {
      var _ref;
      this._diagram = _diagram;
      this._occurr = _occurr;
      SequenceDiagramBuilder.__super__.constructor.call(this);
      if ((_ref = this._diagram) == null) {
        this._diagram = new SequenceDiagram;
      }
    }

    return SequenceDiagramBuilder;

  })(DiagramBuilder);

  SequenceDiagramBuilder.prototype._curr_occurr = function() {
    return this._occurr;
  };

  SequenceDiagramBuilder.prototype._curr_actor = function() {
    return this._occurr._actor;
  };

  SequenceDiagramBuilder.prototype.found = function(sth, callback) {
    var actor;
    actor = this._find_or_create(sth);
    actor.addClass("found");
    this._occurr = actor.activate();
    if (callback != null) {
      callback.apply(this, [this]);
    }
    this._occurr = null;
    return this;
  };

  SequenceDiagram = require("SequenceDiagram");

  core = require("core");

  SequenceObject = require("SequenceObject");

  SequenceDiagramBuilder.prototype._find_or_create = function(sth) {
    var a, obj, r;
    a = core._normalize(sth);
    r = core._to_ref(a.id);
    if (this._diagram[r]) {
      return this._diagram[r];
    }
    obj = new SequenceObject(sth);
    this._diagram._reg_by_ref(a.id, obj);
    this._diagram.append(obj);
    switch (typeof sth) {
      case "string":
        this._diagram._var(r, obj);
        break;
      case "object":
        this._diagram._var(core._to_ref(a.id), obj);
        break;
      default:
        console.error("It must be string or object for", eth);
        throw new Error("Unrecognized argument: " + e);
    }
    return obj;
  };

  SequenceDiagramBuilder.prototype.message = function(a, b, c) {
    var actee, actname, callback, e, iact, it, msg, norm, stereotype;
    actname = a;
    if (typeof b === "function" || b === void 0) {
      actee = this._curr_actor();
      callback = b;
    } else if (typeof a === "string" && typeof b === "string") {
      if (typeof c === "function") {
        actee = this._find_or_create(b);
        callback = c;
      } else if (c === void 0) {
        actee = this._find_or_create(b);
        callback = null;
      }
    } else if (typeof a === "object" && typeof b === "string") {
      actee = this._find_or_create(b);
      callback = c;
      for (e in a) {
        switch (e) {
          case "asynchronous":
            actname = a[e];
            stereotype = "asynchronous";
        }
      }
    } else if (typeof a === "string" && typeof b === "object") {
      norm = JUMLY.Identity.normalize(b);
      actee = this._find_or_create(norm);
      callback = c;
    } else {
      msg = "invalid arguments";
      console.error("SequenceDiagramBuilder::message", msg, a, b, c);
      throw new Error(msg, a, b, c);
    }
    iact = this._curr_occurr().interact(actee);
    iact.find(".name").text(actname).end().find(".message").addClass(stereotype);
    it = new SequenceDiagramBuilder(this._diagram, iact._actee);
    if (callback != null) {
      callback.apply(it, []);
    }
    return it;
  };

  SequenceDiagramBuilder.prototype.create = function(a, b, c) {
    var actee, async, callback, ctxt, e, iact, id, name, norm, occurr;
    if (typeof a === "string" && typeof b === "function") {
      name = null;
      actee = a;
      callback = b;
    } else if (typeof a === "string" && typeof b === "string" && typeof c === "function") {
      name = a;
      actee = b;
      callback = c;
    } else if (typeof a === "string" && b === void 0) {
      name = null;
      actee = a;
      callback = null;
    } else if (typeof a === "object") {
      e = core._normalize(a);
      actee = e.name;
      async = a.asynchronous != null;
      if (typeof b === "function") {
        callback = b;
      }
    }
    if (typeof a === "string") {
      id = core._to_id(actee);
    } else {
      norm = core._normalize(a);
      id = norm.id;
      actee = norm.name;
    }
    iact = this._curr_occurr().create({
      id: id,
      name: actee
    });
    if (name) {
      iact.name(name);
    }
    if (async) {
      iact.find(".message:eq(0)").addClass("asynchronous");
    }
    occurr = iact._actee;
    ctxt = new SequenceDiagramBuilder(this._diagram, occurr);
    if (callback != null) {
      callback.apply(ctxt, []);
    }
    this._var(id, occurr._actor);
    this._diagram._reg_by_ref(id, occurr._actor);
    return ctxt;
  };

  SequenceDiagramBuilder.prototype._var = function(varname, refobj) {
    var ref;
    ref = core._to_ref(varname);
    return this._diagram._var(ref, refobj);
  };

  SequenceDiagramBuilder.prototype.destroy = function(a) {
    this._curr_occurr().destroy(this._find_or_create(a));
    return null;
  };

  SequenceDiagramBuilder.prototype.reply = function(a, b) {
    var f, n, obj, ref;
    obj = b;
    if (typeof b === "string") {
      ref = core._to_ref(core._to_id(b));
      if (this._diagram[ref]) {
        obj = this._diagram[ref];
      }
    }
    f = function(occur, n) {
      if (occur.is_on_another()) {
        return f(occur._parent_occurr(), n + 1);
      } else {
        return n;
      }
    };
    n = f(this._curr_occurr(), 0);
    this._curr_occurr().parents(".interaction:eq(" + n + ")").data("_self").reply({
      name: a,
      ".actee": obj
    });
    return null;
  };

  SequenceDiagramBuilder.prototype.ref = function(a) {
    var SequenceRef, id, occur, r, ref;
    SequenceRef = require("SequenceRef");
    occur = this._curr_occurr();
    ref = new SequenceRef(a);
    if (occur) {
      occur.append(ref);
    } else {
      this.diagram().append(ref);
    }
    id = core._normalize(a).id;
    this._diagram._reg_by_ref(id, ref);
    r = core._to_ref(id);
    this._diagram._var(r, ref);
    return ref;
  };

  SequenceDiagramBuilder.prototype.lost = function(a) {
    this._curr_occurr.lost();
    return null;
  };

  SequenceDiagramBuilder.prototype.loop = function(a, b, c) {
    var SequenceFragment, frag, kids, last, newones;
    last = [].slice.apply(arguments).pop();
    if ($.isFunction(last)) {
      kids = this._curr_occurr().find("> *");
      last.apply(this, []);
      newones = this._curr_occurr().find("> *").not(kids);
      if (newones.length > 0) {
        SequenceFragment = require("SequenceFragment");
        frag = new SequenceFragment().addClass("loop").enclose(newones);
        frag.find(".name:first").html("Loop");
      }
      if (typeof a === "string") {
        frag.find(".condition").html(a);
      }
      return frag;
    }
  };

  SequenceDiagramBuilder.prototype.alt = function(ints) {
    var iacts, name, self, _new_act;
    iacts = {};
    self = this;
    for (name in ints) {
      if (typeof ints[name] !== "function") {
        break;
      }
      _new_act = function(name, act) {
        return function() {
          var nodes, _;
          nodes = [];
          _ = function(it) {
            var node;
            if ((it != null ? it.constructor : void 0) === SequenceDiagramBuilder) {
              node = it._curr_occurr().parent(".interaction:eq(0)");
            } else {
              node = it;
            }
            return nodes.push(node);
          };
          act.apply({
            _curr_actor: function() {
              return self._curr_actor.apply(self, arguments);
            },
            message: function() {
              return _(self.message.apply(self, arguments));
            },
            loop: function() {
              return _(self.loop.apply(self, arguments));
            },
            ref: function() {
              return _(self.ref.apply(self, arguments));
            }
          });
          return nodes;
        };
      };
      iacts[name] = _new_act(name, ints[name]);
    }
    this._curr_occurr().interact({
      stereotype: ".alt"
    }, iacts);
    return this;
  };

  /*
  Examples:
    - @reactivate "do something", "A"
    - @reactivate @message "call a taxi", "Taxi agent"
  */


  SequenceDiagramBuilder.prototype.reactivate = function(a, b, c) {
    var e, occurr;
    if (a.constructor === this.constructor) {
      e = a._curr_occurr.parents(".interaction:eq(0)");
      this._curr_actor().activate().append(e);
      return a;
    }
    occurr = this._curr_actor().activate();
    this._occurr = occurr;
    return this.message(a, b, c);
  };

  SequenceDiagramBuilder.prototype.css = function(styles) {
    return this._diagram.css(styles);
  };

  SequenceDiagramBuilder.prototype.find = function(selector) {
    return this._diagram.find(selector);
  };

  SequenceDiagramBuilder.prototype._note = function(a, b, c) {
    var nodes, note, opts, text;
    nodes = this._curr_occurr.find("> .interaction:eq(0)");
    if (nodes.length === 0) {
      nodes = this._curr_occurr.parents(".interaction:eq(0):not(.activated)");
    }
    text = a;
    opts = b;
    note = jumly(".note", text);
    if (opts) {
      return note.attach(nodes, opts);
    } else {
      return nodes.append(note);
    }
  };

  SequenceDiagramBuilder.prototype.compose = function(opts) {
    if (typeof opts === "function") {
      opts(this._diagram);
    } else {
      if (opts != null) {
        opts.append(this._diagram);
      }
    }
    return this._diagram.compose(opts);
  };

  SequenceDiagramBuilder.prototype.preferences = function() {
    return this._diagram.preferences.apply(this._diagram, arguments);
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceDiagramBuilder;
  } else {
    core.exports(SequenceDiagramBuilder);
  }

}).call(this);
(function() {
  var DiagramLayout, HTMLElementLayout, SequenceDiagramLayout, SequenceLifeline, core, jumly,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  DiagramLayout = require("DiagramLayout");

  $.fn.self = function() {
    return this.data("_self");
  };

  $.fn.selfEach = function(f) {
    return this.each(function(i, e) {
      e = $(e).self();
      if (e == null) {
        throw new Error("_self have nothing ", e);
      }
      f(e);
      return this;
    });
  };

  SequenceDiagramLayout = (function(_super) {

    __extends(SequenceDiagramLayout, _super);

    function SequenceDiagramLayout() {
      return SequenceDiagramLayout.__super__.constructor.apply(this, arguments);
    }

    return SequenceDiagramLayout;

  })(DiagramLayout);

  SequenceDiagramLayout.prototype._q = function(sel) {
    return $(sel, this.diagram);
  };

  SequenceDiagramLayout.prototype._layout_ = function() {
    var l, objs, r;
    objs = $(".object:eq(0) ~ .object", this.diagram);
    $(".object:eq(0)", this.diagram).after(objs);
    this.align_objects_horizontally();
    this._q(".occurrence").each(function(i, e) {
      return $(e).data("_self")._move_horizontally();
    });
    this._q(".occurrence .interaction").selfEach(function(e) {
      return e._compose_();
    });
    this.generate_lifelines_and_align_horizontally();
    this.pack_refs_horizontally();
    this.pack_fragments_horizontally();
    this._q(".create.message").selfEach(function(e) {
      return e._to_be_creation();
    });
    this.align_lifelines_vertically();
    this.align_lifelines_stop_horizontally();
    this.rebuild_asynchronous_self_calling();
    this.render_icons();
    objs = this.diagram.find(".object");
    l = objs.min(function(e) {
      return $(e).offset().left;
    });
    r = objs.max(function(e) {
      return $(e).offset().left + $(e).outerWidth() - 1;
    });
    return this.diagram.width(r - l + 1);
  };

  HTMLElementLayout = require("HTMLElementLayout");

  SequenceDiagramLayout.prototype.align_objects_horizontally = function() {
    var f0, f1,
      _this = this;
    f0 = function(a) {
      if (a.css("left") === "auto") {
        return a.css({
          left: 0
        });
      }
    };
    f1 = function(a, b) {
      var spacing;
      if (b.css("left") === "auto") {
        spacing = new HTMLElementLayout.HorizontalSpacing(a, b);
        return spacing.apply();
      }
    };
    return this._q(".object").pickup2(f0, f1);
  };

  jumly = $.jumly;

  SequenceLifeline = require("SequenceLifeline");

  SequenceDiagramLayout.prototype.generate_lifelines_and_align_horizontally = function() {
    var diag;
    diag = this.diagram;
    return $(".object", this.diagram).each(function(i, e) {
      var a, obj;
      obj = $(e).data("_self");
      a = new SequenceLifeline(obj);
      a.offset({
        left: obj.offset().left
      });
      a.width(obj.preferred_width());
      return diag.append(a);
    });
  };

  SequenceDiagramLayout.prototype.pack_refs_horizontally = function() {
    return this._q(".ref").selfEach(function(ref) {
      var idx, not_defined, parent, pw;
      pw = ref.preferred_left_and_width();
      ref.offset({
        left: pw.left
      });
      idx = ref.index();
      parent = ref.parent();
      ref.detach();
      not_defined = ref.css("width") === "0px";
      if (idx === 0) {
        parent.prepend(ref);
      } else {
        ref.insertAfter(parent.find("> *:eq(" + (idx - 1) + ")"));
      }
      if (not_defined) {
        return ref.width(pw.width);
      } else {
        return ref.width(parseInt(ref.css("width")));
      }
    });
  };

  SequenceDiagramLayout.prototype.pack_fragments_horizontally = function() {
    var fixwidth, fragments, left, most;
    fragments = $("> .fragment", this.diagram);
    if (fragments.length > 0) {
      most = this._q(".object").mostLeftRight();
      left = fragments.offset().left;
      fragments.width((most.right - left) + (most.left - left));
    }
    fixwidth = function(fragment) {
      var msg;
      most = $(".occurrence, .message, .fragment", fragment).not(".return, .lost").mostLeftRight();
      fragment.width(most.width() - (fragment.outerWidth() - fragment.width()));
      msg = jumly(fragment.find("> .interaction > .message"))[0];
      if (msg != null ? msg.isTowardLeft() : void 0) {
        return fragment.offset({
          left: most.left
        }).find("> .interaction > .occurrence").each(function(i, occurr) {
          occurr = jumly(occurr)[0];
          return occurr._move_horizontally().prev().offset({
            left: occurr.offset().left
          });
        });
      }
    };
    return this._q(".occurrence > .fragment").selfEach(fixwidth).parents(".occurrence > .fragment").selfEach(fixwidth);
  };

  SequenceDiagramLayout.prototype.align_lifelines_vertically = function() {
    var last, mh, min, nodes;
    nodes = this.diagram.find(".interaction, > .ref");
    if (nodes.length === 0) {
      return;
    }
    if (nodes.filter(".ref").length > 0) {
      last = nodes.filter(":last");
      mh = last.offset().top + last.outerHeight() - nodes.filter(":first").offset().top;
    } else {
      mh = this.diagram.find(".interaction:eq(0)").height();
    }
    min = this.diagram.find(".object").min(function(e) {
      return $(e).offset().top;
    });
    return this._q(".lifeline").each(function(i, e) {
      var a, dh, mt, ot;
      a = $(e).data("_self");
      a.offset({
        left: a._object.offset().left
      });
      ot = Math.ceil(a._object.offset().top);
      dh = ot - min;
      a.height(mh - dh + 16);
      mt = a.offset().top - (ot + a._object.outerHeight());
      return a.css({
        "margin-top": "-" + mt + "px"
      });
    });
  };

  SequenceDiagramLayout.prototype.align_lifelines_stop_horizontally = function() {
    return $(".stop", this.diagram).each(function(i, e) {
      var occurr;
      e = $(e);
      occurr = e.prev(".occurrence");
      return e.offset({
        left: occurr.offset().left
      });
    });
  };

  SequenceDiagramLayout.prototype.rebuild_asynchronous_self_calling = function() {
    return this.diagram.find(".message.asynchronous").parents(".interaction:eq(0)").each(function(i, e) {
      var iact, msg, occurr, prev;
      e = $(e).self();
      if (!e.isToSelf()) {
        return;
      }
      iact = e.addClass("activated").addClass("asynchronous");
      prev = iact.parents(".interaction:eq(0)");
      iact.insertAfter(prev);
      occurr = iact.css("padding-bottom", 0).find("> .occurrence").self()._move_horizontally().css("top", 0);
      msg = iact.find(".message").self();
      return msg.css("z-index", -1).offset({
        left: occurr.offset().left,
        top: prev.find(".occurrence").outerBottom() - msg.height() / 3
      });
    });
  };

  SequenceDiagramLayout.prototype.render_icons = function() {
    return this._q(".object").selfEach(function(e) {
      return typeof e.renderIcon === "function" ? e.renderIcon() : void 0;
    });
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceDiagramLayout;
  } else {
    core.exports(SequenceDiagramLayout);
  }

}).call(this);
(function() {
  var HTMLElement, SequenceFragment, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  SequenceFragment = (function(_super) {

    __extends(SequenceFragment, _super);

    function SequenceFragment(args) {
      SequenceFragment.__super__.constructor.call(this, args, function(me) {
        return me.append($("<div>").addClass("header").append($("<div>").addClass("name")).append($("<div>").addClass("condition")));
      });
    }

    return SequenceFragment;

  })(HTMLElement);

  SequenceFragment.prototype.enclose = function(_) {
    var a, b, i, _i, _ref;
    if (!(_ != null) || _.length === 0) {
      throw "SequenceFragment::enclose arguments are empty.";
    }
    if (_.length > 1) {
      a = $(_[0]).parent()[0];
      for (i = _i = 1, _ref = _.length - 1; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
        b = $(_[i]).parent()[0];
        if (a !== b) {
          throw {
            message: "different parent",
            nodes: [a, b]
          };
        }
      }
    }
    if (_.parent === void 0) {
      return this;
    }
    this.swallow(_);
    return this;
  };

  SequenceFragment.prototype.extendWidth = function(opts) {
    var dlw, drw, frag;
    frag = this;
    dlw = opts != null ? opts.left : void 0;
    drw = opts != null ? opts.right : void 0;
    if (dlw == null) {
      dlw = 0;
    }
    if (drw == null) {
      drw = 0;
    }
    frag.css("position", "relative").css("left", -dlw).width(frag.width() + dlw / 2).find("> .interaction").css("margin-left", dlw);
    return frag.width(frag.outerWidth() + drw);
  };

  SequenceFragment.prototype.alter = function(occurr, acts) {
    var alt, name, nodes;
    alt = this;
    alt.addClass("alt").find(".condition").remove();
    occurr.append(alt);
    for (name in acts) {
      nodes = acts[name]();
      if (nodes.length === 0) {
        continue;
      }
      alt.append($("<div>").addClass("condition").html(name));
      alt.append(nodes);
      alt.append($("<div>").addClass("divider"));
    }
    alt.find(".divider:last").remove();
    return alt;
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceFragment;
  } else {
    core.exports(SequenceFragment);
  }

}).call(this);
(function() {
  var HTMLElement, SequenceRef, core,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  HTMLElement = require("HTMLElement");

  SequenceRef = (function(_super) {

    __extends(SequenceRef, _super);

    function SequenceRef(args) {
      SequenceRef.__super__.constructor.call(this, args, function(div) {
        return div.append($("<div>").addClass("header").append($("<div>").addClass("tag").html("ref"))).append($("<div>").addClass("name"));
      });
    }

    return SequenceRef;

  })(HTMLElement);

  SequenceRef.prototype.preferred_left_and_width = function() {
    var alt, d, dh, diag, dl, iact, it, l, left, lines, most, objs, occurs, r, w;
    diag = this.parents(".sequence-diagram:eq(0)");
    iact = this.prevAll(".interaction:eq(0)");
    if (iact.length === 0) {
      lines = $(".lifeline .line", diag);
      most = lines.mostLeftRight();
      most.width = most.width();
      return most;
    }
    objs = diag.find(".object");
    if (objs.length === 0) {
      return {};
    }
    if (objs.length === 1) {
      it = objs.filter(":eq(0)");
      w = parseInt(this.css("min-width") || this.css("max-width") || this.css("width"));
      l = it.offset().left - (w - it.outerWidth()) / 2;
      if ((dl = l - it.offset().left) < 0) {
        this.css({
          "margin-left": dl
        });
        diag.css({
          "margin-left": -dl
        });
      }
      return {
        left: "auto"
      };
    }
    if ((alt = this.parents(".alt:eq(0)")).length === 1) {
      left = alt.parents(".occurrence");
      l = left.offset().left + left.outerWidth() - 1;
      r = this.parent().find(".occurrence").max(function(e) {
        return $(e).offset().left + $(e).outerWidth() / 2;
      });
      d = left.outerWidth() / 2 - 1;
      return {
        left: l - d,
        width: r - l
      };
    }
    dh = diag.self().find(".occurrence:eq(0)").width();
    occurs = iact.find(".occurrence");
    most = occurs.mostLeftRight();
    most.left -= dh;
    most.width = most.width();
    return most;
  };

  core = require("core");

  if (core.env.is_node) {
    module.exports = SequenceRef;
  } else {
    core.exports(SequenceRef);
  }

}).call(this);
(function() {
  var JUMLYUsecaseDiagram, JUMLYUsecaseDiagramBuilder, UMLActor, UMLSystemBoundary, UMLUsecase, bind_between, set_min_size, shift_usecase_down_to_above,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  UMLUsecase = (function() {

    function UMLUsecase(props, opts) {
      jQuery.extend(this, UMLUsecase.newNode());
      this;

    }

    UMLUsecase.newNode = function() {
      return $("<div>").addClass("usecase").append($("<div>").addClass("icon").append($("<div>").addClass("name")));
    };

    return UMLUsecase;

  })();

  UMLUsecase.prototype.pack = function(T) {
    var R, h, icon, minheight, minwidth, name, t, v;
    if (T == null) {
      T = (1 + 2.2360679) / 2;
    }
    icon = this.find(".icon");
    name = this.find(".icon .name");
    minwidth = icon.css("min-width").toInt();
    minheight = icon.css("min-height").toInt();
    R = minwidth / minheight;
    h = icon.height();
    v = name.height();
    t = h / v;
    if (t > T) {
      t = T;
    }
    return icon.css({
      width: minwidth * t,
      height: minheight * t
    });
  };

  UMLActor = (function() {

    function UMLActor(props, opts) {
      jQuery.extend(this, $.jumly(".object"));
      this.iconify(".actor");
      this.addClass("actor");
      this;

    }

    return UMLActor;

  })();

  UMLSystemBoundary = (function() {

    function UMLSystemBoundary(props, opts) {
      jQuery.extend(this, UMLSystemBoundary.newNode());
      this;

    }

    UMLSystemBoundary.newNode = function() {
      return $("<div>").addClass("system-boundary").append($("<div>").addClass("name"));
    };

    return UMLSystemBoundary;

  })();

  JUMLYUsecaseDiagram = (function(_super) {

    __extends(JUMLYUsecaseDiagram, _super);

    function JUMLYUsecaseDiagram() {
      return JUMLYUsecaseDiagram.__super__.constructor.apply(this, arguments);
    }

    return JUMLYUsecaseDiagram;

  })(require("Diagram"));

  set_min_size = function(nodes) {
    return nodes.each(function(i, e) {
      var h, w;
      e = $(e);
      if (w = e.css("min-width")) {
        e.width(w).css({
          width: w
        });
      }
      if (h = e.css("min-height")) {
        return e.height(h).css({
          height: h
        });
      }
    });
  };

  shift_usecase_down_to_above = function(nodes) {
    return nodes.each(function(i, e) {
      return $(e).find("> .usecase .icon").each(function(i, e) {
        e = $(e);
        if (i > 0) {
          return e.css("margin-top", -e.css("min-height").toInt() / 3);
        }
      });
    });
  };

  bind_between = function(nodes, diag) {
    return nodes.each(function(i, e) {
      var bind, find_with_id, src;
      src = $(e).self();
      find_with_id = function(id) {
        var t;
        if (diag[id]) {
          return diag[id];
        }
        if (!((typeof id === "string") || (typeof id === "number"))) {
          return id;
        }
        if ((t = $("#" + id, diag)).length > 0) {
          return t;
        }
      };
      bind = function(type) {
        return $(src.jprops()[type]).each(function(i, e) {
          var dst, link;
          if (!(dst = find_with_id(e))) {
            return;
          }
          link = $.jumly(".relationship", {
            src: src,
            dst: dst
          });
          link.addClass(type);
          return diag.append(link);
        });
      };
      bind("use");
      bind("extend");
      return bind("include");
    });
  };

  JUMLYUsecaseDiagram.prototype.align_actors_ = function() {
    var actors, dh, height, tb;
    tb = this.find(".system-boundary").mostTopBottom();
    height = tb.height();
    actors = this.find(".actor");
    dh = height / actors.length;
    return actors.each(function(i, e) {
      var dy, y;
      dy = i > 1 ? (i % 2 === 0 ? dh : -dh) : 0;
      y = tb.top + dy + height / 2;
      return $(e).offset({
        top: y
      });
    });
  };

  JUMLYUsecaseDiagram.prototype.render = function() {
    return this.find(".relationship").each(function(i, e) {
      return $(e).self().render();
    });
  };

  JUMLYUsecaseDiagram.prototype.compose = function() {
    set_min_size(this.find(".usecase .icon"));
    shift_usecase_down_to_above(this.find(".system-boundary"));
    bind_between(this.find(".usecase, .actor"), this);
    this.align_actors_();
    this.render();
    this.height(this.mostTopBottom().height());
    return this;
  };

  JUMLYUsecaseDiagramBuilder = (function(_super) {

    __extends(JUMLYUsecaseDiagramBuilder, _super);

    function JUMLYUsecaseDiagramBuilder(_diagram, _boundary) {
      this._diagram = _diagram;
      this._boundary = _boundary;
    }

    return JUMLYUsecaseDiagramBuilder;

  })(require("DiagramBuilder"));

  JUMLYUsecaseDiagramBuilder.prototype.new_ = function(type, uname) {
    var a;
    uname = $.jumly.normalize(uname);
    a = $.jumly(type, uname);
    $.extend(a.jprops(), uname);
    return a;
  };

  JUMLYUsecaseDiagramBuilder.prototype._declare_ = function(uname, type, target) {
    var a, b, ref;
    a = this.new_(type, uname);
    target.append(a);
    b = JUMLY.Identity.normalize(uname);
    ref = this._diagram._regByRef_(b.id, a);
    return eval("" + ref + " = a");
  };

  JUMLYUsecaseDiagramBuilder.prototype.usecase = function(uname) {
    return this._declare_(uname, ".usecase", this._boundary);
  };

  JUMLYUsecaseDiagramBuilder.prototype.actor = function(uname) {
    return this._declare_(uname, ".actor", this._diagram);
  };

  JUMLYUsecaseDiagramBuilder.prototype.boundary = function(name, acts) {
    var boundary, ctxt, id, norm;
    if (!this._diagram) {
      this._diagram = this.diagram;
    }
    if (name == null) {
      name = "";
    }
    if (id = $.jumly.identify(name)) {
      return curry_(this, this.boundary, id);
    }
    boundary = this.new_(".system-boundary", name);
    ctxt = new JUMLYUsecaseDiagramBuilder(this._diagram, boundary);
    ctxt.diagram = this._diagram;
    acts.apply(ctxt);
    if (this._boundary) {
      this._boundary.append(boundary);
    } else {
      this._diagram.append(boundary);
    }
    norm = JUMLY.Identity.normalize(name);
    this._diagram._regByRef_(norm.id);
    return this;
  };

  JUMLYUsecaseDiagramBuilder.prototype.compose = function(something) {
    if (typeof something === "function") {
      something(this._diagram);
    } else if (typeof something === "object" && something.each) {
      something.append(this._diagram);
    } else {
      throw something + " MUST be a function or a jQuery object";
    }
    this._diagram.compose();
    return this;
  };

  JUMLYUsecaseDiagram.prototype.boundary = function(name, acts) {
    var ctxt;
    ctxt = new JUMLYUsecaseDiagramBuilder(this);
    ctxt.boundary(name, acts);
    return ctxt;
  };

}).call(this);
(function() {
  var JUMLY, consts, icon, _STYLES, _actor_renderer, _controller_renderer, _entity_renderer, _path, _render_actor, _render_controller, _render_entity, _render_icon, _render_view, _size_canvas, _view_renderer;

  JUMLY = window.JUMLY;

  _STYLES = {
    radius: 14,
    lineWidth: 1.5,
    fillStyle: 'white',
    strokeStyle: 'gray',
    shadowBlur: 4,
    shadowColor: 'rgba(0,0,0,0.33)',
    shadowOffsetX: 10,
    shadowOffsetY: 5
  };

  consts = {
    ACTOR_HEAD: 8,
    VIEW_RADIUS: 14,
    CONTROLLER_RADIUS: 14,
    ENTITY_RADIUS: 14
  };

  _path = $.g2d.path;

  _actor_renderer = function(ctxt, styles) {
    var exth, lw, r, r0, r1, r2, ret;
    r = styles.radius * 0.66 || consts.ACTOR_HEAD;
    r2 = r * 2;
    exth = r * 0.25;
    lw = Math.round(styles.lineWidth);
    r0 = function() {
      ctxt.arc(lw + r, lw + r, r, 0, Math.PI * 2, true);
      ctxt.fill();
      ctxt.shadowColor = 'transparent';
      return ctxt.stroke();
    };
    r1 = function() {
      var dh, dv;
      dh = 3 * lw;
      dv = r2 * 0.85;
      new _path(ctxt).moveTo(0, r2 + lw + exth).line(lw + r2 + lw, 0).moveTo(lw + r, r2 + lw).line(0, r2 * 0.35).line(-r2 + dh, dv).move(r2 - dh, -dv).line(r2 - dh - 1, dv - 1);
      ctxt.shadowColor = styles.shadowColor;
      return ctxt.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + lw,
        height: lw + r2 * 2 + lw
      },
      paths: [r0, r1]
    };
  };

  _view_renderer = function(ctxt, styles) {
    var extw, lw, r, r0, r1, r2, ret;
    r = styles.radius || consts.VIEW_RADIUS;
    r2 = r * 2;
    extw = r * 0.4;
    lw = styles.lineWidth;
    r0 = function() {
      ctxt.arc(lw + r + extw, lw + r, r, 0, Math.PI * 2, true);
      ctxt.fill();
      ctxt.shadowColor = 'transparent';
      return ctxt.stroke();
    };
    r1 = function() {
      new _path(ctxt).moveTo(lw, r).line(extw, 0).moveTo(lw, 0).line(0, r2);
      return ctxt.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + extw + lw,
        height: lw + r2 + lw
      },
      paths: [r0, r1]
    };
  };

  _controller_renderer = function(ctxt, styles) {
    var dy, effectext, exth, lh, lw, r, r0, r1, r2, ret;
    r = styles.radius || consts.CONTROLLER_RADIUS;
    r2 = r * 2;
    exth = r * 0.4;
    lw = lh = styles.lineWidth;
    dy = 0;
    effectext = 0;
    r0 = function() {
      ctxt.arc(lw + r, lw + r + exth, r, 0, Math.PI * 2, true);
      ctxt.fill();
      ctxt.shadowColor = 'transparent';
      return ctxt.stroke();
    };
    r1 = function() {
      new _path(ctxt).moveTo(lw + r, lh + exth).lineTo(lw + r * 1.4, lh + exth / 4).moveTo(lw + r, lh + exth).lineTo(lw + r * 1.4, lh + exth * 7 / 4);
      return ctxt.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + lw + effectext,
        height: lw + r2 + lw + effectext + exth
      },
      paths: [r0, r1]
    };
  };

  _entity_renderer = function(ctxt, styles) {
    var exth, lw, r, r0, r1, r2, ret;
    r = styles.radius || consts.ENTITY_RADIUS;
    r2 = r * 2;
    exth = r * 0.4;
    lw = styles.lineWidth;
    r0 = function() {
      ctxt.arc(lw + r, lw + r, r, 0, Math.PI * 2, true);
      ctxt.fill();
      ctxt.shadowColor = 'transparent';
      return ctxt.stroke();
    };
    r1 = function() {
      ctxt.shadowColor = styles.shadowColor;
      new _path(ctxt).moveTo(lw + r, r2).lineTo(lw + r, r2 + exth).moveTo(0, r2 + exth).lineTo(r2 + lw, r2 + exth);
      return ctxt.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + lw,
        height: lw + r2 + exth + lw
      },
      paths: [r0, r1]
    };
  };

  _size_canvas = function(canvas, size, styles) {
    var dh, dw;
    dw = styles.shadowOffsetX + styles.shadowBlur || 0;
    dh = styles.shadowOffsetY + styles.shadowBlur || 0;
    $(canvas).attr({
      width: size.width + dw,
      height: size.height + dh
    });
    return size;
  };

  _render_icon = function(canvas, renderer, args) {
    var ctxt, e, paths, r, size, styles, _i, _len, _ref;
    args = args || {};
    styles = $.extend(_STYLES, args);
    ctxt = canvas.getContext('2d');
    _ref = renderer(ctxt, styles), size = _ref.size, paths = _ref.paths;
    _size_canvas(canvas, size, styles);
    $.extend(ctxt, styles);
    for (_i = 0, _len = paths.length; _i < _len; _i++) {
      e = paths[_i];
      ctxt.beginPath();
      e();
    }
    return r = {
      size: size,
      styles: styles
    };
  };

  _render_actor = function(canvas, styles) {
    return _render_icon(canvas, _actor_renderer, styles);
  };

  _render_view = function(canvas, styles) {
    return _render_icon(canvas, _view_renderer, styles);
  };

  _render_controller = function(canvas, styles) {
    return _render_icon(canvas, _controller_renderer, styles);
  };

  _render_entity = function(canvas, args) {
    return _render_icon(canvas, _entity_renderer, args);
  };

  icon = {};

  $.extend(icon, {
    ".actor": _render_actor,
    ".view": _render_view,
    ".controller": _render_controller,
    ".entity": _render_entity
  });

}).call(this);
(function() {



}).call(this);
(function() {
  var jumlyBind, ko, name2builder;

  jumlyBind = {
    init: function(elem, val, bindings, model) {},
    update: function(elem, val, bindings, model) {
      var diag, koarg, _base, _base1;
      koarg = {
        element: elem,
        valueAccessor: val,
        allBindingsAccessor: bindings,
        viewModel: model
      };
      diag = ko.utils.unwrapObservable(val());
      try {
        $(elem).html(diag);
        if (diag.compose == null) {
          throw diag;
        }
        diag.compose();
        return typeof (_base = bindings()).success === "function" ? _base.success({
          diagram: diag,
          ko: koarg
        }) : void 0;
      } catch (ex) {
        return typeof (_base1 = bindings()).error === "function" ? _base1.error($.extend(ex, {
          type: ex.constructor.name,
          diagram: diag,
          ko: koarg
        })) : void 0;
      }
    }
  };

  name2builder = {
    sequence: "SequenceDiagramBuilder"
  };

  ko = {
    dependentObservable: function(observableJumlipt, builder) {
      if (!ko.isObservable(observableJumlipt)) {
        throw new JUMLY.Error("not_observable", "is not observable", [observableJumlipt]);
      }
      if (typeof builder === "string") {
        builder = name2builder[builder.toLowerCase()];
      }
      return ko.dependentObservable(function() {
        try {
          return (new builder).build(observableJumlipt());
        } catch (ex) {
          return ex;
        }
      });
    }
  };

  $(function() {});

}).call(this);
