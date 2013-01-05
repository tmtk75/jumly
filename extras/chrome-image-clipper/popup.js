var mktrans = function(ctx, w, h, newc, is_bg) {
  var imgd = ctx.getImageData(0, 0, w, h);
  var pix = imgd.data;

  for (var i = 0, n = pix.length; i < n; i += 4) {
    var r = pix[i + 0];
    var g = pix[i + 1];
    var b = pix[i + 2];
    var a = pix[i + 3];
    //if (r == 255 && g == 255 && b == 255) { 
    if (is_bg(r, g, b)) { 
      pix[i + 0] = newc.r;
      pix[i + 1] = newc.g;
      pix[i + 2] = newc.b;
      pix[i + 3] = newc.a;
    }
  }
  ctx.putImageData(imgd, 0, 0);
}

var render = function(img, dx, dy, w, h) {
  offscreen.width  = w;
  offscreen.height = h;
  var ctx = offscreen.getContext('2d');
  ctx.globalCompositeOperation = "lighter";
  //ctx.globalAlpha = 0.5
  ctx.drawImage(img,
                dx, dy, w, h,
                0, 0, w, h);

  //var newc = {r:0, g:0, b:0, a:0};
  var newc = {r:255, g:255, b:255, a:255.0};
  var is_bg = function(r, g, b) {
    var d = 8;
    return (r >= (238 - d) && g >= (238 - d) && b >= (238 - d)) && !(r == 255 && g == 255 && b == 255);
  }
  mktrans(ctx, w, h, newc, is_bg);

  downloader.data.value = offscreen.toDataURL('png');
  downloader.submit();
}

var main = function() {
  chrome.tabs.getSelected(null, function(tab) {
    chrome.tabs.sendRequest(tab.id, {type:"JUMLY", action:"request-dimension"}, function(args) {
      if (!args.width) {
        $(notification).addClass("failed").html("Any diagrams not found");
        return;      
      }
      var width = args.width,
          height = args.height,
          left = args.left,
          top = args.top;
      
      var opts = {format:'png'};
      var f = function(data) {
        var img = new Image();
        img.width  = width;
        img.height = height;
        img.src = data;
        //NOTE: setTimeout is workaround for invalidating canvas
        setTimeout(function() {render(img, left, top, width, height);}, 0);
        $(notification).addClass("succeeded").html("Download succeeded");
      }
      chrome.tabs.captureVisibleTab(null, opts, f);
    });
  })
}
$(main);
