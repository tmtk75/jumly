var fs  = require("fs"),
    cwd = fs.workingDirectory;

var tmp_html = cwd + "/a.html";
var img_path = cwd + "/a.png";

var page = new WebPage;
page.open(tmp_html, function() {
  page.viewportSize = {left:0, top:0, width:100, height:100}
  page.clipRect = page.viewportSize
  page.render(img_path);
  console.log(img_path);
  phantom.exit();
});

