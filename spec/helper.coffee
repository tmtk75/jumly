class JUMLYSpecHelper
  @mkscript: (type, script)->
               $("<script>").attr("type", "application/jumly+#{type}")
                            .text script

for p of JUMLYSpecHelper
  window[p] = JUMLYSpecHelper[p]
