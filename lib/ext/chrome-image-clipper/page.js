$(function() {
  chrome.extension.onRequest.addListener(function(request, sender, respond) {
    if (request.type != "JUMLY" || request.action != "request-dimension") {
      return;
    }

    var diag = $(".diagram", document.body);
    if (diag.length == 0) {
      return respond({});
    }

    var a = $.extend({}, diag.offset(), {width: diag.outerWidth(), height: diag.outerHeight()});
    
    var body = $("body")
    a.left += parseInt(body.css("border-left-width"));
    a.top  += parseInt(body.css("border-top-width"));

    var m = diag.find(".participant .name").css("box-shadow").match(/.*([0-9]+px [0-9]+px [0-9]+px [0-9]+px)/);
    var pxs = m[1].split("px");
    var extw = parseInt(pxs[0]);
    var exth = parseInt(pxs[1]);

    a.width  += extw;
    if (exth >= 16) {
      //WORKAROUND: 16 is a literal number for lifeline in SequenceDiagramLayout
      //console.log("calibrate for box-shadow");
      a.height += exth - 16;
    }

    respond(a);
  });
});
