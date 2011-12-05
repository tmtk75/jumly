


DSL
===============================================================================

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



API
===============================================================================

### `$.jumly.runScript <HTMLScriptElement>`

    $.jumly.runScript $("script")[0]



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
    JUMLY.preference
      color:"red"
      "font-size":13px
    </script>

This is simple function call.
You can put it any script elements you like.

If you'd like to use javascript, you can write:

    <script type="text/javascript">
    JUMLY.preference({color:"red", "font-size:13px"});
    </script>



