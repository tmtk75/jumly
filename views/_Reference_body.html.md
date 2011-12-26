Check [Notation](#notation) and  [Terminology](#terminology) out first.

Scripting
===============================================================================

MIME Type
--------------------------------------------------------------------------------
JUMLY supports a MIME Type format, `application/jumly+{diagram-type}`.

`{diagram-type}` is parameterized. it takes:

  - **Structure Diagram**
    - class
    - component
    - object
    - composite-structure
    - deployment
    - pacakge
  - **Behaviour Diagram**
    - activity
    - usecase
    - state-machine
    - **Interaction Diagram**
      - sequence
      - interaction-overview
      - communication (collaboration)
      - timing
  - **Other Diagram**
    - robustness



Name / ID
===============================================================================
- JUMLY-HTMLElement almost has more than one Named-HTMLElement, which is classified with `name`.
- JUMLY-HTMLElement MUST have id attribute at the top HTMLElement.

All JUMLY diagrams consist of HTMLElement including \<canvas>.
Some kinds of HTMLElement have `id` attribute.
Usually value of name becomes id value. If a HTML document has more than two id attributes which are same value,
its behavior is undefined.

See [here](#jumly-objectstring) about way to give name.


JUMLY-HTMLElement
-------------------------------------------------------------------------------
Here is specification for implicit identification.

- JUMLY generates an appropriate ID value if you don't set any IDs or give any names.
- It's sequencial number, which lifecycle is from HTMLDocument loading to the next reload.
- Its start number is more than 1.

Here is specification for named identification.

- JUMLY uses the name value if you set a name and don't give any IDs.
- JUMLY converts the value base on a rule.
- JUMLY converts all [A-Z] to lower-case.
- JUMLY keeps [0-9_].
- Apart from above character, JUMLY converts all to '-' (hyphen).

Here is specification for explicit identification.

- JUMLY uses the ID value if you explicitly give it.
- You can use number and string as ID value.
- ID number is represented with a regular expression `^[0-9]$`
- ID string is represented with a regular expression `^[a-zA-Z_]$`


JUMLY-DiagramElement
-------------------------------------------------------------------------------
- If you use same value more thatn two times in a diagram, JUMLY throws exception.
TBD.


### How to refer JUMLY-HTMLElement
In order to refer each element, JUMLY provides Ref.
Ref is generally notated as id value.
It's sometimes modified by JUMLY avoid confusing and syntax error.

There are three ways to refer JUMLY-HTMLElement in diagram.

- With ref variable
- With jQuery selector
- As property of diagram

For example, when a definition is given, it shows the each way. 

    @class "User"
    @class "App"
    @class "Mobile Phone"
    ## Change font-color.
    user.css color:"red"                       # With ref variable
    @diagram.find("#app").css color:"green"    # With jQuery selector
    @diagram["mobile-phone"].css color:"blue"  # As property of diagram


### JUMLY-ClassDiagramElement
All class elemens in class diagram have `.attrs` and `.mathods` child element,
which have some `.attribute` and `.method`.
They are identified by ID which is formed in:

  < class ID > '-' < attr \| method > '-' < its name >
  
For example,
- `dog-method-balk`
- `cat-attr-name`



Accesing by ID
-------------------------------------------------------------------------------
JUMLY-HTMLElement is an usual HTMLElement, so you can use jQuery or other JavaScript libraries
in order to find HTMLElement and do something. It's not different from the case of typical usage of jQuery.

    <script type="text/jumly+class">
    @class "Animal":
      methods: ["walk", "balk"]
    $("#animal").css color:"red", ...
    </script>

JUMLY also provides another way to access JUMLY-HTMLElement.

    <script type="text/jumly+class">
    @class "Person":
      methods: ["walk", "talk"]
    @_["person"].css color:"blue", ...
    </script>

You can use `@_` keyword (actually just property).



Preference
===============================================================================

Diagram Preference
-------------------------------------------------------------------------------
**Diagram Preference** is configuration for each diagram.
Diagram Preference usually forms like:

    <script type="text/jumly+class">
    @preference
      color:"red"
      "font-size":13px
    </script>

Diagram Preference is usually used in order to configure
CSS properties before composing it.


JUMLY Preference
-------------------------------------------------------------------------------
**JUMLY Preference** is global configuration.

    <script type="text/coffeescript">
    $.jumly.preference
      color:"red"
      "font-size":13px
    </script>

This is simple function call.
You can put it any script elements you like.

If you'd like to use javascript, you can write:

    <script type="application/javascript">
    $.jumly.preference({color:"red", "font-size:13px"});
    </script>



Build Diagram
===============================================================================
When HTML DOM tree is built,
JUMLY builds all HTMLScriptElement having type attribute the value is
formed with `'application/jumly+{diagramType}'` expect for elements
suppressed explicitly.

For example,

    <script type="application/jumly+usecase">
    ...
    
In order to suppress building at the time,
you can append a class to HTMLScriptElement, which is `ignore` like this.

    <script type="application/jumly+usecase" class="ignored">
    ...

If you use [$.jumly.build][], you can build them later.
It's helpful that you get JUMLY better to add a plugin.

    $("script.ignored").each (idx, script)-> $.jumly.build script


  [$.jumly.build]: #jumlybuild-htmlscriptelement



Event
===============================================================================
JUMLY supports some observable events using [jQuery.Event][].

- `.diagram`
  - `compose.before`
  - `compose.after`

  [jQuery.Event]: http://api.jquery.com/trigger/



jQuery.data
===============================================================================
JUMLY stores a few properties using jQuery.data.

- jumly:property
- jumly:...

TBD.



API
===============================================================================
JUMLY provides a root function as a jQuery extention `$.jumly`,
and all objects and functions related with JUMLY belong to the root object.

Core
--------------------------------------------------------------------------------

### `$.jumly <object|string>`

- $.jumly accepts `object` or `string`.
- when object, it SHOULD have `name` property.
- when string, JUMLY assigns it to the value of Named-HTMLElement.
  This is short notation for giving object.

For example, below is same.

     $.jumly name:"Person"
     $.jumly "Person"
        

### `JUMLY-DiagramElement $.jumly.build <HTMLScriptElement>`

    $.jumly.build $("script")[0], [options]



JUMLY DSL
===============================================================================
As an assumption, CoffeeScript is able to be used.

Directive Form
-------------------------------------------------------------------------------
As for most directives, the arguments are expected like followings.

    @<directive>(<string|integer>) <arg0>, <arg1>, ...


Common
-------------------------------------------------------------------------------

### `@note`


Use-case
-------------------------------------------------------------------------------

### `@usecase`

### `@actor`


Class
-------------------------------------------------------------------------------

### `@def`


Sequence
-------------------------------------------------------------------------------

### `@found`

### `@message`

### `@create`

### `@destroy`

### `@reply`

### `@lost`

### `@loop`

### `@ref`

### `@alt`

### `@reactivate`

### `@iconify`



Notation
===============================================================================
- `.{string}` shows a class attribute value, which starts with `.`.



Terminology
===============================================================================
<dl>
	<dt>HTMLDocument</dt>
	<dd>General HTML document. JavaScript document object.</dd>
	<dt>HTMLElement</dt>
	<dd>General HTML element in DOM tree of HTML document.</dd>
	<dt>JUMLY-HTMLElement</dt>
	<dd>Kind of HTMLElement which is created by JUMLY. JUMLY-HTMLElement contains HTMLElement.</dd>
    <dt>JUMLY-DiagramElement</dt>
    <dd>Kind of JUMLY-HTMLElement consists of JUMLY-HTMLElement, which has class attribute <code>diagram</code>.</dd>
	<dt>Named-HTMLElement</dt>
	<dd>HTMLElement having class <code>name</code>, which is usually contained by JUMLY-HTMLElement.</dd>
</dl>

For example,

    <div class="message" id="Hello"><!-- JUMLY-HTMLElement -->
      <div class="name">Hello</div><!-- Named-HTMLElement -->
        ...

<dl>
	<dt>[options]</dt>
	<dd>Means a hash object or arguments liken arg1, arg2, ...</dd>
</dl>
