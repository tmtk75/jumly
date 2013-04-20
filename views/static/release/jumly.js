(function() {
  var JUMLY, SCRIPT_TYPE_PATTERN, core, exported, self, _compilers, _evalHTMLScriptElement, _layouts, _new_builder, _new_layout, _runScripts, _to_type_string,
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

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

  self = {};

  if (core.env.is_node) {
    global.JUMLY = JUMLY;
    module.exports = core;
    self.require = require;
  } else {
    window.JUMLY = JUMLY;
    exported = {
      core: core,
      "node-jquery": {},
      "./jasmine-matchers": {}
    };
    JUMLY.require = function(name) {
      if (name === void 0 || name === null) {
        throw new Error("" + name + " was not properly given");
      }
      if (!exported[name]) {
        console.warn("not found:", name);
      }
      return exported[name];
    };
    self.require = JUMLY.require;
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

  _new_builder = function(type) {
    return function(script) {
      return (new (self.require(type))).build(script.html());
    };
  };

  _new_layout = function(type) {
    return function(diagram) {
      return (new (self.require(type))).layout(diagram);
    };
  };

  _compilers = {
    '.sequence-diagram': _new_builder("SequenceDiagramBuilder"),
    '.robustness-diagram': _new_builder("RobustnessDiagramBuilder")
  };

  _layouts = {
    '.sequence-diagram': _new_layout("SequenceDiagramLayout"),
    '.robustness-diagram': _new_layout("RobustnessDiagramLayout")
  };

  _runScripts = function() {
    var diagrams, s, script, scripts, _i, _len;

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
      if (!$(script).data('jumly-evaluated')) {
        _evalHTMLScriptElement(script);
        $(script).data('jumly-evaluated', true);
      }
    }
    return null;
  };

  if (!core.env.is_node) {
    if (typeof $ !== 'undefined') {
      $(window).on('DOMContentLoaded', _runScripts);
    } else if (window.addEventListener) {
      window.addEventListener('DOMContentLoaded', _runScripts);
    } else {
      throw "window.addEventListener is not supported";
    }
  }

}).call(this);

/*
This is capable to render followings:
- Synmetric figure
- Poly-line
*/


(function() {
  var Shape, core, g2d, self, shape_arrow, to_polar_from_cartesian, _line_to, _render_both, _render_dashed, _render_dashed2, _render_line, _render_line2, _render_normal;

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
      for (i = _i = 0, _ref = p.radius - 1; plen > 0 ? _i <= _ref : _i >= _ref; i = _i += plen) {
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

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  g2d = {
    arrow: shape_arrow,
    path: Shape
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = g2d;
  } else {
    core.exports(g2d, "jquery.g2d");
  }

}).call(this);

(function() {
  var core, self, utils, _choose;

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  $.fn.outerBottom = function() {
    return this.offset().top + this.outerHeight() - 1;
  };

  _choose = function(nodes, ef, cmpf) {
    return $.map(nodes, ef).sort(cmpf)[0];
  };

  utils = {
    max: function(nodes, ef) {
      return _choose(nodes, ef, function(a, b) {
        return b - a;
      });
    },
    min: function(nodes, ef) {
      return _choose(nodes, ef, function(a, b) {
        return a - b;
      });
    },
    mostLeftRight: function(objs, margin) {
      return {
        left: this.min(objs, function(e) {
          return $(e).offset().left - (margin ? parseInt($(e).css("margin-left")) : 0);
        }),
        right: this.max(objs, function(e) {
          var t;

          t = $(e).offset().left + $(e).outerWidth() + (margin ? parseInt($(e).css("margin-right")) : 0);
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
    },
    mostTopBottom: function(objs, margin) {
      return {
        top: this.min(objs, function(e) {
          return $(e).offset().top - (margin ? parseInt($(e).css("margin-top")) : 0);
        }),
        bottom: this.max(objs, function(e) {
          var t;

          t = $(e).offset().top + $(e).outerHeight() + (margin ? parseInt($(e).css("margin-bottom")) : 0);
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
    }
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = utils;
  } else {
    core.exports(utils, "jquery.ext");
  }

}).call(this);

(function() {
  var HTMLElement, core, self;

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

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
      return (s.match(/Diagram$/) ? s.replace(/Diagram$/, "-Diagram") : s.match(/NoteElement/) ? s.replace(/Element$/, "") : s.replace(/^[A-Z][a-z]+/, "")).toLowerCase();
    };

    return HTMLElement;

  })();

  HTMLElement.prototype.preferred_width = function() {
    return this.find("> *:eq(0)").outerWidth();
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = HTMLElement;
  } else {
    core.exports(HTMLElement);
  }

}).call(this);

(function() {
  var Diagram, HTMLElement, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  core = self.require("core");

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

  Diagram.prototype._reg_by_ref = function(id, obj) {
    var exists, ref;

    exists = function(id, diag) {
      return $("#" + id).length > 0;
    };
    ref = core._to_ref(id);
    if (this[ref]) {
      throw new Error("Already exists for '" + ref + "'");
    }
    if (exists(id, this)) {
      throw new Error("Element which has same ID(" + id + ") already exists in the document.");
    }
    this[ref] = obj;
    return ref;
  };

  if (core.env.is_node) {
    module.exports = Diagram;
  } else {
    core.exports(Diagram);
  }

}).call(this);

(function() {
  var CoffeeScript, DiagramBuilder, core, self;

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  DiagramBuilder = (function() {
    function DiagramBuilder() {}

    return DiagramBuilder;

  })();

  core = self.require("core");

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

  DiagramBuilder.prototype._refer = function(ref, adv) {
    var id, r;

    id = core._normalize(adv.by).id;
    this._diagram._reg_by_ref(id, ref);
    r = core._to_ref(id);
    return this._diagram._var(r, ref);
  };

  if (core.env.is_node) {
    module.exports = DiagramBuilder;
  } else {
    core.exports(DiagramBuilder);
  }

}).call(this);

(function() {
  var DiagramLayout, core, self;

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  DiagramLayout = (function() {
    function DiagramLayout() {}

    return DiagramLayout;

  })();

  DiagramLayout.prototype.layout = function(diagram) {
    this.diagram = diagram;
    return typeof this._layout === "function" ? this._layout() : void 0;
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = DiagramLayout;
  } else {
    core.exports(DiagramLayout);
  }

}).call(this);

(function() {
  var HorizontalSpacing, core, root, self;

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

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

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = root;
  } else {
    core.exports(root, "HTMLElementLayout");
  }

}).call(this);

(function() {
  var HTMLElement, NoteElement, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  NoteElement = (function(_super) {
    __extends(NoteElement, _super);

    function NoteElement(args, attrs) {
      NoteElement.__super__.constructor.call(this, args, function(me) {
        return me.append($("<div>").addClass("name"));
      });
      if (attrs) {
        this.css(attrs.css);
      }
    }

    return NoteElement;

  })(HTMLElement);

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = NoteElement;
  } else {
    core.exports(NoteElement);
  }

}).call(this);

(function() {
  var Position, PositionLeft, PositionLeftRight, PositionRightLeft, PositionTop, core, self, _ref, _ref1, _ref2, _ref3,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

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
      _ref = PositionRightLeft.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return PositionRightLeft;

  })(Position);

  PositionLeftRight = (function(_super) {
    __extends(PositionLeftRight, _super);

    function PositionLeftRight() {
      _ref1 = PositionLeftRight.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    return PositionLeftRight;

  })(Position);

  PositionLeft = (function(_super) {
    __extends(PositionLeft, _super);

    function PositionLeft() {
      _ref2 = PositionLeft.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    return PositionLeft;

  })(Position);

  PositionTop = (function(_super) {
    __extends(PositionTop, _super);

    function PositionTop() {
      _ref3 = PositionTop.__super__.constructor.apply(this, arguments);
      return _ref3;
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

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = Position;
  } else {
    core.exports(Position);
  }

}).call(this);

(function() {
  var HTMLElement, MESSAGE_STYLE, Relationship, core, cssAsInt, g2d, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  g2d = self.require("jquery.g2d");

  Relationship = (function(_super) {
    __extends(Relationship, _super);

    function Relationship(args, opts) {
      this.src = opts.src;
      this.dst = opts.dst;
      Relationship.__super__.constructor.call(this, args, function(me) {
        return me.addClass("relationship").append($("<canvas>").addClass("icon")).append($("<div>").addClass("name"));
      });
    }

    return Relationship;

  })(HTMLElement);

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

  cssAsInt = function(node, name) {
    var a;

    a = node.css(name);
    if (a) {
      return parseInt(a);
    } else {
      return 0;
    }
  };

  Relationship.prototype._point = function(obj) {
    var dh, dv, margin_left, margin_top, s;

    margin_left = cssAsInt($("body"), "margin-left");
    margin_top = cssAsInt($("body"), "margin-top");
    s = obj.offset();
    dh = -(cssAsInt(obj, "margin-left")) - margin_left;
    dv = -(cssAsInt(obj, "margin-top")) - margin_top;
    return {
      left: s.left + obj.outerWidth() / 2 + dh,
      top: s.top + obj.outerHeight() / 2 + dv
    };
  };

  Relationship.prototype._rect = function(p, q) {
    var a, b, h, hs, l, vs, w;

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
    return {
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

  Relationship.prototype.render = function() {
    var aa, bb, cc, cr, ctxt, dd, p, q, r, s, style, t;

    p = this._point(this.src);
    q = this._point(this.dst);
    r = this._rect(p, q);
    cr = 2;
    aa = r.hunit * this.dst.outerWidth() / cr;
    bb = r.vunit * this.dst.outerHeight() / cr;
    cc = r.hunit * this.src.outerWidth() / cr;
    dd = r.vunit * this.src.outerHeight() / cr;
    s = {
      x: p.left - r.left + cc,
      y: p.top - r.top + dd
    };
    t = {
      x: q.left - r.left - aa,
      y: q.top - r.top - bb
    };
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
    style = $.extend({}, MESSAGE_STYLE, {
      pattern: [4, 4],
      shape: 'line'
    });
    if (this.hasClass("extend")) {
      style = $.extend(style, {
        shape: 'dashed'
      });
    }
    g2d.arrow(ctxt, s, t, style);
    return ctxt.restore();
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = Relationship;
  } else {
    core.exports(Relationship);
  }

}).call(this);

(function() {
  var HTMLElement, SequenceLifeline, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  SequenceLifeline = (function(_super) {
    __extends(SequenceLifeline, _super);

    function SequenceLifeline(_object) {
      this._object = _object;
      self = this;
      SequenceLifeline.__super__.constructor.call(this, null, function(me) {
        return me.append($("<div>").addClass("line")).width(self._object.width());
      });
    }

    return SequenceLifeline;

  })(HTMLElement);

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = SequenceLifeline;
  } else {
    core.exports(SequenceLifeline);
  }

}).call(this);

(function() {
  var HTMLElement, MESSAGE_STYLE, STEREOTYPE_STYLES, SequenceMessage, core, g2d, self, _determine_primary_stereotype,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  g2d = self.require("jquery.g2d");

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
    var e, outerRight, src;

    e = this._toLine(this._srcOccurr(), this._dstOccurr()._actor, canvas);
    if (this.isTowardLeft()) {
      src = this._srcOccurr();
      outerRight = function(it) {
        return it.offset().left + it.outerWidth();
      };
      e.dst.x = outerRight(src._actor) - src.offset().left;
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

  SequenceMessage.prototype.repaint = function() {
    var a, arrow, canvas, ctxt, gap, line, llw, newdst, newsrc, p, rcx, rey, shape;

    shape = STEREOTYPE_STYLES[_determine_primary_stereotype(this)];
    arrow = jQuery.extend({}, MESSAGE_STYLE, shape);
    canvas = this._current_canvas = this._prefferedCanvas();
    if (false) {
      p = this.parents(".occurrence:eq(0)");
      arrow.fillStyle = p.css("background-color");
      arrow.strokeStyle = p.css("border-top-color");
      (p.css("box-shadow")).match(/(rgba\(.*\)) ([0-9]+)px ([0-9]+)px ([0-9]+)px ([0-9]+)px/);
      arrow.shadowColor = RegExp.$1;
      arrow.shadowOffsetX = RegExp.$2;
      arrow.shadowOffsetY = RegExp.$3;
      arrow.shadowBlur = RegExp.$4;
    }
    if (this.hasClass("self")) {
      ctxt = canvas[0].getContext('2d');
      gap = 2;
      rcx = this.width() - (gap + 4);
      rey = this.height() - (arrow.height / 2 + 4);
      llw = this._dstOccurr().outerWidth();
      g2d.arrow(ctxt, {
        x: rcx,
        y: rey
      }, {
        x: llw + gap,
        y: rey
      }, arrow);
      arrow.base = 0;
      g2d.arrow(ctxt, {
        x: llw / 2 + gap,
        y: gap
      }, {
        x: rcx,
        y: gap
      }, arrow);
      g2d.arrow(ctxt, {
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
    if (this.hasClass("reverse")) {
      a = line.src;
      line.src = line.dst;
      line.dst = a;
      arrow.shape = 'dashed';
    }
    g2d.arrow(canvas[0].getContext('2d'), line.src, line.dst, arrow);
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
      var mt, obj;

      obj = dst._actor;
      obj.offset({
        top: msg.offset().top - obj.height() / 3
      });
      mt = parseInt(dst.css("margin-top"));
      return dst.offset({
        top: obj.outerBottom() + mt
      });
    };
    this.outerWidth((line_width(this)) + src.outerWidth() - 1);
    return shift_downward(this);
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = SequenceMessage;
  } else {
    core.exports(SequenceMessage);
  }

}).call(this);

(function() {
  var HTMLElement, SequenceInteraction, SequenceMessage, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  SequenceInteraction = (function(_super) {
    __extends(SequenceInteraction, _super);

    function SequenceInteraction(_actor, _actee) {
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
      if ((e != null ? e.gives(".participant") : void 0) === obj) {
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
      }).addClass("reverse").repaint();
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
    msg.addClass("self");
    msg.repaint();
    arrow = msg.find(".arrow");
    return msg.find(".name").offset({
      left: arrow.offset().left + arrow.outerWidth(),
      top: arrow.offset().top
    });
  };

  SequenceMessage = self.require("SequenceMessage");

  SequenceInteraction.prototype.reply = function(p) {
    var a, name;

    this.addClass("reply");
    a = new SequenceMessage(this, p != null ? p[".actee"] : void 0).addClass("return").insertAfter(this.children(".occurrence:eq(0)"));
    name = function(it) {
      if (it != null ? it.name : void 0) {
        return it.name;
      }
      return $(p).find(".name:eq(0)").text();
    };
    $(a).find(".name:eq(0)").text(name(p));
    return this;
  };

  SequenceInteraction.prototype.fragment = function(attrs, opts) {
    var SequenceFragment, frag;

    SequenceFragment = self.require("SequenceFragment");
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

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = SequenceInteraction;
  } else {
    core.exports(SequenceInteraction);
  }

}).call(this);

(function() {
  var HTMLElement, SequenceInteraction, SequenceOccurrence, core, self, utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  utils = self.require("jquery.ext");

  SequenceOccurrence = (function(_super) {
    __extends(SequenceOccurrence, _super);

    function SequenceOccurrence(_actor) {
      this._actor = _actor;
      SequenceOccurrence.__super__.constructor.call(this);
    }

    return SequenceOccurrence;

  })(HTMLElement);

  core = self.require("core");

  SequenceInteraction = self.require("SequenceInteraction");

  SequenceOccurrence.prototype.interact = function(actor, acts) {
    var SequenceFragment, alt, iact, occurr;

    if ((acts != null ? acts.stereotype : void 0) === ".lost") {
      occurr = new SequenceOccurrence().addClass("icon");
      iact = new SequenceInteraction(this, occurr);
      iact.addClass("lost");
    } else if ((acts != null ? acts.stereotype : void 0) === ".destroy") {

    } else if ((actor != null ? actor.stereotype : void 0) === ".alt") {
      SequenceFragment = self.require("SequenceFragment");
      alt = new SequenceFragment("alt");
      alt.alter(this, acts);
      return this;
    } else {
      occurr = new SequenceOccurrence(actor);
      iact = new SequenceInteraction(this, occurr);
    }
    if (actor === iact._actor._actor) {
      iact.addClass("self");
    }
    iact.append(occurr).appendTo(this);
    return iact;
  };

  SequenceOccurrence.prototype.create = function(objsrc) {
    var SequenceParticipant, iact, obj;

    SequenceParticipant = self.require("SequenceParticipant");
    obj = new SequenceParticipant(objsrc.name).addClass("created-by");
    this._actor.parent().append(obj);
    return iact = (this.interact(obj)).addClass("creating").find(".message").addClass("create").end();
  };

  SequenceOccurrence.prototype._move_horizontally = function() {
    var left;

    if (this.parent().hasClass("lost")) {
      offset({
        left: utils.mostLeftRight(this.parents(".diagram").find(".participant")).right
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
      if (a.gives(".participant") === obj) {
        return a;
      }
      return f(a);
    };
    return f(this);
  };

  SequenceOccurrence.prototype.destroy = function(actee) {
    var occur;

    occur = this.interact(actee).data("_self")._actee;
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
  var HTMLElement, SequenceInteraction, SequenceOccurrence, SequenceParticipant, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  SequenceParticipant = (function(_super) {
    __extends(SequenceParticipant, _super);

    function SequenceParticipant(args) {
      SequenceParticipant.__super__.constructor.call(this, args, function(me) {
        return me.append($("<div>").addClass("name"));
      });
    }

    return SequenceParticipant;

  })(HTMLElement);

  core = self.require("core");

  SequenceOccurrence = self.require("SequenceOccurrence");

  SequenceInteraction = self.require("SequenceInteraction");

  SequenceParticipant.prototype.activate = function() {
    var iact, occurr;

    occurr = new SequenceOccurrence(this);
    iact = new SequenceInteraction(null, occurr);
    iact.addClass("activated");
    iact.find(".message").remove();
    iact.append(occurr);
    this.parent().append(iact);
    return occurr;
  };

  SequenceParticipant.prototype.isLeftAt = function(a) {
    return this.offset().left < a.offset().left;
  };

  SequenceParticipant.prototype.isRightAt = function(a) {
    return (a.offset().left + a.width()) < this.offset().left;
  };

  SequenceParticipant.prototype.iconify = function(fixture, styles) {
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

  SequenceParticipant.prototype.lost = function() {
    return this.activate().interact(null, {
      stereotype: ".lost"
    });
  };

  if (core.env.is_node) {
    module.exports = SequenceParticipant;
  } else {
    core.exports(SequenceParticipant);
  }

}).call(this);

(function() {
  var HTMLElement, SequenceFragment, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

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

    if ((_ == null) || _.length === 0) {
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

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = SequenceFragment;
  } else {
    core.exports(SequenceFragment);
  }

}).call(this);

(function() {
  var HTMLElement, SequenceRef, core, self, utils,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

  utils = self.require("jquery.ext");

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
    var alt, d, dh, diag, dl, iact, it, l, left, lines, most, objs, occurr, occurs, r, right, w;

    occurr = this.parents(".occurrence:eq(0)");
    if (occurr.length === 1) {
      w = occurr.outerWidth();
      right = occurr.offset().left + w;
      return {
        left: right - w / 2
      };
    }
    diag = this.parents(".sequence-diagram:eq(0)");
    iact = this.prevAll(".interaction:eq(0)");
    if (iact.length === 0) {
      lines = $(".lifeline .line", diag);
      most = utils.mostLeftRight(lines);
      most.width = most.width();
      return most;
    }
    objs = diag.find(".participant");
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
      r = utils.max(this.parent().find(".occurrence"), function(e) {
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
    most = utils.mostLeftRight(occurs);
    most.left -= dh;
    most.width = most.width();
    return most;
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = SequenceRef;
  } else {
    core.exports(SequenceRef);
  }

}).call(this);

(function() {
  var Diagram, HTMLElement, SequenceDiagram, core, jumly, prefs_, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  HTMLElement = self.require("HTMLElement");

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

  Diagram = self.require("Diagram");

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

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = SequenceDiagram;
  } else {
    core.exports(SequenceDiagram);
  }

}).call(this);

(function() {
  var DiagramBuilder, NoteElement, SequenceDiagram, SequenceDiagramBuilder, SequenceFragment, SequenceParticipant, SequenceRef, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  core = self.require("core");

  DiagramBuilder = self.require("DiagramBuilder");

  SequenceDiagram = self.require("SequenceDiagram");

  SequenceParticipant = self.require("SequenceParticipant");

  SequenceRef = self.require("SequenceRef");

  SequenceFragment = self.require("SequenceFragment");

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

  SequenceDiagramBuilder.prototype._find_or_create = function(sth) {
    var a, obj, r;

    a = core._normalize(sth);
    r = core._to_ref(a.id);
    if (this._diagram[r]) {
      return this._diagram[r];
    }
    obj = new SequenceParticipant(sth);
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
    if ((typeof a === "string") && (typeof b === "function" || b === void 0)) {
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
    var occur, ref;

    occur = this._curr_occurr();
    ref = new SequenceRef(a);
    if (occur) {
      occur.append(ref);
    } else {
      this.diagram().append(ref);
    }
    this._refer(ref, {
      by: a
    });
    return ref;
  };

  SequenceDiagramBuilder.prototype.lost = function(a) {
    this._curr_occurr.lost();
    return null;
  };

  SequenceDiagramBuilder.prototype.fragment = function(nctx) {
    var ctx, frag, name;

    for (name in nctx) {
      ctx = nctx[name];
      frag = this._fragment(ctx, {
        label: name
      });
      this._refer(frag, {
        by: name
      });
      return;
    }
  };

  SequenceDiagramBuilder.prototype.loop = function(a, b, c) {
    var last;

    last = [].slice.apply(arguments).pop();
    if (!$.isFunction(last)) {
      return;
    }
    return this._fragment(last, {
      kind: "loop",
      label: "Loop"
    }, a);
  };

  SequenceDiagramBuilder.prototype._fragment = function(last, opts, desc) {
    var frag, kids, newones;

    kids = this._curr_occurr().find("> *");
    last.apply(this, []);
    newones = this._curr_occurr().find("> *").not(kids);
    if (newones.length > 0) {
      frag = new SequenceFragment();
      if (opts.kind) {
        frag.addClass(opts.kind);
      }
      frag.enclose(newones);
      frag.find(".name:first").html(opts.label);
    }
    if (typeof desc === "string") {
      frag.find(".condition").html(desc);
    }
    return frag;
  };

  SequenceDiagramBuilder.prototype.alt = function(ints) {
    var iacts, name, _new_act;

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

  NoteElement = self.require("NoteElement");

  SequenceDiagramBuilder.prototype.note = function(text, opts) {
    var note;

    note = new NoteElement(text, opts);
    return this._curr_occurr().append(note);
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

  if (core.env.is_node) {
    module.exports = SequenceDiagramBuilder;
  } else {
    core.exports(SequenceDiagramBuilder);
  }

}).call(this);

(function() {
  var DiagramLayout, HTMLElementLayout, SequenceDiagramLayout, SequenceLifeline, core, self, utils, _, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  DiagramLayout = self.require("DiagramLayout");

  utils = self.require("jquery.ext");

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
      _ref = SequenceDiagramLayout.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return SequenceDiagramLayout;

  })(DiagramLayout);

  SequenceDiagramLayout.prototype._q = function(sel) {
    return $(sel, this.diagram);
  };

  SequenceDiagramLayout.prototype._layout = function() {
    var l, ml, mr, objs, occurs, r;

    objs = $(".participant:eq(0) ~ .participant", this.diagram);
    $(".participant:eq(0)", this.diagram).after(objs);
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
    this.diagram.find(".return").each(function(i, e) {
      e = $(e);
      return e.css("margin-top", -e.height() / 2);
    });
    occurs = this.diagram.find(".occurrence");
    ml = occurs.sort(function(e) {
      return $(e).offset().left;
    });
    mr = occurs.sort(function(e) {
      return $(e).offset().left + $(e).outerWidth() - 1;
    });
    $(ml[0]).addClass("leftmost");
    $(mr[mr.length - 1]).addClass("rightmost");
    objs = this.diagram.find(".participant");
    l = utils.min(objs, function(e) {
      return $(e).offset().left;
    });
    r = utils.max(objs, function(e) {
      return $(e).offset().left + $(e).outerWidth() - 1;
    });
    return this.diagram.width(r - l + 1);
  };

  HTMLElementLayout = self.require("HTMLElementLayout");

  _ = function(opts) {
    if (typeof navigator !== "undefined" && navigator !== null ? navigator.userAgent.match(/.*(WebKit).*/) : void 0) {
      return opts["webkit"];
    }
    if (typeof navigator !== "undefined" && navigator !== null ? navigator.userAgent.match(/.*(Gecko).*/) : void 0) {
      return opts["gecko"];
    }
    return opts["webkit"];
  };

  $.fn.pickup2 = function(f0, f1, f2) {
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

  SequenceDiagramLayout.prototype.align_objects_horizontally = function() {
    var f0, f1,
      _this = this;

    f0 = function(a) {
      if (a.css("left") === (_({
        webkit: "auto",
        gecko: "0px"
      }))) {
        return a.css({
          left: 0
        });
      }
    };
    f1 = function(a, b) {
      var spacing;

      if (b.css("left") === (_({
        webkit: "auto",
        gecko: "0px"
      }))) {
        spacing = new HTMLElementLayout.HorizontalSpacing(a, b);
        return spacing.apply();
      }
    };
    return this._q(".participant").pickup2(f0, f1);
  };

  SequenceLifeline = self.require("SequenceLifeline");

  SequenceDiagramLayout.prototype.generate_lifelines_and_align_horizontally = function() {
    var diag;

    diag = this.diagram;
    return $(".participant", this.diagram).each(function(i, e) {
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
      most = utils.mostLeftRight(this._q(".participant"));
      left = fragments.offset().left;
      fragments.width((most.right - left) + (most.left - left));
    }
    fixwidth = function(fragment) {
      var msg;

      most = utils.mostLeftRight($(".occurrence, .message, .fragment", fragment).not(".return, .lost"));
      fragment.width(most.width() - (fragment.outerWidth() - fragment.width()));
      msg = fragment.find("> .interaction > .message").data("_self");
      if (msg != null ? msg.isTowardLeft() : void 0) {
        return fragment.offset({
          left: most.left
        }).find("> .interaction > .occurrence").each(function(i, occurr) {
          occurr = occurr.data("_self");
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
    min = utils.min(this.diagram.find(".participant"), function(e) {
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
    return this._q(".participant").selfEach(function(e) {
      return typeof e.renderIcon === "function" ? e.renderIcon() : void 0;
    });
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = SequenceDiagramLayout;
  } else {
    core.exports(SequenceDiagramLayout);
  }

}).call(this);

(function() {
  var HTMLElement, IconElement, Path, core, g2d, self, _STYLES, _actor, _controller, _entity, _render, _view,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  g2d = self.require("jquery.g2d");

  _STYLES = {
    lineWidth: 1.5,
    fillStyle: 'white',
    strokeStyle: 'gray',
    shadowBlur: 12,
    shadowColor: 'rgba(0,0,0,0.22)',
    shadowOffsetX: 8,
    shadowOffsetY: 5
  };

  Path = g2d.path;

  _actor = function(ctx, styles) {
    var exth, lw, r, r0, r1, r2, ret;

    r = styles.radius || 12;
    r2 = r * 2;
    exth = r * 0.25;
    lw = Math.round(styles.lineWidth);
    r0 = function() {
      ctx.arc(lw + r, lw + r, r, 0, Math.PI * 2, true);
      ctx.fill();
      ctx.shadowColor = 'transparent';
      return ctx.stroke();
    };
    r1 = function() {
      var dh, dv;

      dh = 3 * lw;
      dv = r2 * 0.77;
      new Path(ctx).moveTo(0, r2 + lw + exth).line(lw + r2 + lw, 0).moveTo(lw + r, r2 + lw).line(0, r2 * 0.35).line(-r, dv).move(r, -dv).line(r, dv);
      ctx.shadowColor = styles.shadowColor;
      return ctx.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + lw,
        height: lw + r2 * 2 + lw
      },
      paths: [r0, r1]
    };
  };

  _view = function(ctx, styles) {
    var extw, lw, r, r0, r1, r2, ret;

    r = styles.radius || 16;
    r2 = r * 2;
    extw = r * 0.4;
    lw = styles.lineWidth;
    r0 = function() {
      ctx.arc(lw + r + extw, lw + r, r, 0, Math.PI * 2, true);
      ctx.fill();
      ctx.shadowColor = 'transparent';
      return ctx.stroke();
    };
    r1 = function() {
      new Path(ctx).moveTo(lw, r).line(extw, 0).moveTo(lw, 0).line(0, r2);
      return ctx.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + extw + lw,
        height: lw + r2 + lw
      },
      paths: [r0, r1]
    };
  };

  _controller = function(ctx, styles) {
    var dy, effectext, exth, lh, lw, r, r0, r1, r2, ret;

    r = styles.radius || 16;
    r2 = r * 2;
    exth = r * 0.4;
    lw = lh = styles.lineWidth;
    dy = 0;
    effectext = 0;
    r0 = function() {
      ctx.arc(lw + r, lw + r + exth, r, 0, Math.PI * 2, true);
      ctx.fill();
      ctx.shadowColor = 'transparent';
      return ctx.stroke();
    };
    r1 = function() {
      var x0, x1, y0;

      x0 = lw + r * 0.8;
      x1 = lw + r * 1.2;
      y0 = lh + exth;
      new Path(ctx).moveTo(x0, y0).lineTo(x1, lh + exth / 4).moveTo(x0, y0).lineTo(x1, lh + exth * 7 / 4);
      return ctx.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + lw + effectext,
        height: lw + r2 + lw + effectext + exth
      },
      paths: [r0, r1]
    };
  };

  _entity = function(ctx, styles) {
    var exth, lw, r, r0, r1, r2, ret;

    r = styles.radius || 16;
    r2 = r * 2;
    exth = r * 0.4;
    lw = styles.lineWidth;
    r0 = function() {
      ctx.arc(lw + r, lw + r, r, 0, Math.PI * 2, true);
      ctx.fill();
      ctx.shadowColor = 'transparent';
      return ctx.stroke();
    };
    r1 = function() {
      ctx.shadowColor = styles.shadowColor;
      new Path(ctx).moveTo(lw + r, r2).lineTo(lw + r, r2 + exth).moveTo(0, r2 + exth).lineTo(r2 + lw, r2 + exth);
      return ctx.stroke();
    };
    return ret = {
      size: {
        width: lw + r2 + lw,
        height: lw + r2 + exth + lw
      },
      paths: [r0, r1]
    };
  };

  _render = function(canvas, renderer, args) {
    var ctx, dh, dw, e, paths, size, styles, _i, _len, _ref, _results;

    if (!canvas.getContext) {
      return;
    }
    styles = $.extend({}, _STYLES, args);
    ctx = canvas.getContext('2d');
    _ref = renderer(ctx, styles), size = _ref.size, paths = _ref.paths;
    dw = (styles.shadowOffsetX || 0) + (styles.shadowBlur / 2 || 0);
    dh = (styles.shadowOffsetY || 0) + (styles.shadowBlur / 2 || 0);
    $(canvas).attr({
      width: size.width + dw,
      height: size.height + dh,
      "data-actual-width": size.width,
      "data-actual-height": size.height
    });
    $.extend(ctx, styles);
    _results = [];
    for (_i = 0, _len = paths.length; _i < _len; _i++) {
      e = paths[_i];
      ctx.beginPath();
      _results.push(e());
    }
    return _results;
  };

  core = self.require("core");

  HTMLElement = self.require("HTMLElement");

  IconElement = (function(_super) {
    __extends(IconElement, _super);

    IconElement.renderer = function(type) {
      var r;

      r = {
        actor: _actor,
        view: _view,
        controller: _controller,
        entity: _entity
      };
      return function(canvas, styles) {
        return _render(canvas, r[type], styles);
      };
    };

    function IconElement(args, opts) {
      var idname;

      idname = core._normalize(args);
      IconElement.__super__.constructor.call(this, args, function(me) {
        var canvas, div;

        canvas = $("<canvas>");
        me.addClass("icon").addClass(opts.kind).append(div = $("<div>").append(canvas)).append($("<div>").addClass("name").append(idname.name));
        (IconElement.renderer(opts.kind))(canvas[0]);
        return div.css({
          height: canvas.data("actual-height")
        });
      });
    }

    return IconElement;

  })(HTMLElement);

  if (core.env.is_node) {
    module.exports = IconElement;
  } else {
    core.exports(IconElement);
  }

}).call(this);

(function() {
  var Diagram, IconElement, RobustnessDiagram, core, self, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  Diagram = self.require("Diagram");

  IconElement = self.require("IconElement");

  RobustnessDiagram = (function(_super) {
    __extends(RobustnessDiagram, _super);

    function RobustnessDiagram() {
      _ref = RobustnessDiagram.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return RobustnessDiagram;

  })(Diagram);

  core = self.require("core");

  RobustnessDiagram.prototype._node_of = function(n, k) {
    var e, id, ref;

    id = core._to_id(n);
    ref = core._to_ref(id);
    if (this[ref]) {
      return this[ref];
    }
    e = new IconElement(n, {
      kind: k
    });
    this._reg_by_ref(id, e);
    return e;
  };

  if (core.env.is_node) {
    module.exports = RobustnessDiagram;
  } else {
    core.exports(RobustnessDiagram);
  }

}).call(this);

(function() {
  var DiagramBuilder, IconElement, Relationship, RobustnessDiagram, RobustnessDiagramBuilder, core, self,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  DiagramBuilder = self.require("DiagramBuilder");

  RobustnessDiagram = self.require("RobustnessDiagram");

  IconElement = self.require("IconElement");

  Relationship = self.require("Relationship");

  RobustnessDiagramBuilder = (function(_super) {
    __extends(RobustnessDiagramBuilder, _super);

    function RobustnessDiagramBuilder(_diagram) {
      var _ref;

      this._diagram = _diagram;
      RobustnessDiagramBuilder.__super__.constructor.call(this);
      if ((_ref = this._diagram) == null) {
        this._diagram = new RobustnessDiagram;
      }
    }

    return RobustnessDiagramBuilder;

  })(DiagramBuilder);

  RobustnessDiagramBuilder.prototype.build = function(src) {
    var _this = this;

    if (src.data) {
      src.find("*[data-kind]").each(function(e) {
        e = $(e);
        return _this._diagram.append(new IconElement(e.text(), {
          kind: $(e).data("kind")
        }));
      });
    } else {
      RobustnessDiagramBuilder.__super__.build.call(this, src);
    }
    return this._diagram;
  };

  core = self.require("core");

  RobustnessDiagramBuilder.prototype._node = function(opt, kind) {
    var a, b, f, k;

    if (typeof opt === "string") {
      this._diagram.append((a = this._diagram._node_of(opt, kind)));
      return a;
    } else if (typeof opt === "object") {
      for (k in opt) {
        if (typeof (f = opt[k]) === "function") {
          a = this._diagram._node_of(k, kind);
          b = f.apply(this, []);
          this._diagram.append(a).append(b);
          this._diagram.append(new Relationship("", {
            src: a,
            dst: b
          }));
          return a;
        }
      }
    }
    throw "unexpected: " + typeof opt;
  };

  RobustnessDiagramBuilder.prototype.actor = function(opt) {
    return this._node(opt, "actor");
  };

  RobustnessDiagramBuilder.prototype.view = function(opt) {
    return this._node(opt, "view");
  };

  RobustnessDiagramBuilder.prototype.controller = function(opt) {
    return this._node(opt, "controller");
  };

  RobustnessDiagramBuilder.prototype.entity = function(opt) {
    return this._node(opt, "entity");
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = RobustnessDiagramBuilder;
  } else {
    core.exports(RobustnessDiagramBuilder);
  }

}).call(this);

(function() {
  var DiagramLayout, RobustnessDiagramLayout, core, self, utils, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  self = {
    require: typeof require !== "undefined" ? require : JUMLY.require
  };

  DiagramLayout = self.require("DiagramLayout");

  utils = self.require("jquery.ext");

  RobustnessDiagramLayout = (function(_super) {
    __extends(RobustnessDiagramLayout, _super);

    function RobustnessDiagramLayout() {
      _ref = RobustnessDiagramLayout.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return RobustnessDiagramLayout;

  })(DiagramLayout);

  RobustnessDiagramLayout.prototype._layout = function() {
    var elems, mlr, mtb, p;

    elems = this.diagram.find(".element");
    p = this.diagram.offset();
    p.left += (parseInt(this.diagram.css("padding-left"))) * 2;
    p.top += (parseInt(this.diagram.css("padding-top"))) * 2;
    elems.each(function(i, e) {
      return $(e).css({
        position: "absolute"
      }).offset({
        left: p.left + (i % 3) * 120,
        top: p.top + (i / 3) * 100
      });
    });
    mlr = utils.mostLeftRight(elems, true);
    mtb = utils.mostTopBottom(elems, true);
    this.diagram.width(mlr.width()).height(mtb.height());
    return this.diagram.find(".relationship").each(function(i, e) {
      return $(e).data("_self").render();
    });
  };

  core = self.require("core");

  if (core.env.is_node) {
    module.exports = RobustnessDiagramLayout;
  } else {
    core.exports(RobustnessDiagramLayout);
  }

}).call(this);
