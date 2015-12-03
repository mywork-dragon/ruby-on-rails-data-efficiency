offerViews = choose(SKUIOfferView);
offerView = null;

found = false;

startTime = Date.now();

function isDownloading(b) {
  var start = Date.now();
  downloading = false;
  // will poll for 2 seconds
  while (Date.now() - start < 2000 && !downloading) {
    var contents = b.layer.contents.toString();
    // More than 1 buffers indicates activity 
    if (contents.match(/buffer/g).length > 1) {
      downloading = true;
    }
  }

  return downloading;
}

// displays the text with the specified color. If ui_color is null, shows green
// ui_color should be a UIColor object
function updateDebugStatus(text, ui_color) {

  function CGPointMake(x, y) { return {x:x, y:y}; }
  function CGSizeMake(w, h) { return {width:w, height:h}; }
  function CGRectMake(x, y, w, h) { return {origin:CGPointMake(x,y), size:CGSizeMake(w, h)}; }

  var w = UIApp.windows[0];

  w.rootViewController.view;

  var label = [UILabel new];
  label.frame = CGRectMake(0, 0, 320, 50);
  label.text = text;
  label.backgroundColor = ui_color || [UIColor greenColor];

  [w.rootViewController.view addSubview:label];
}


while(Date.now() - startTime < 10000 && !found)
{
  for each (var anOfferView in offerViews)
  {
    if (anOfferView.superview != null)
    {
      offerView = anOfferView;
      found = true;
      break;
    }
  }
}

if (!found)
{
  throw "Could not find button";
}

offerViewSubviews = offerView.subviews;
button = offerViewSubviews[0];

if (isDownloading(button)) {
  updateDebugStatus("Downloading", [UIColor yellowColor]);
  throw "Downloading";
}

title = (button.title === null ? null : button.title.toString());

if (title === "OPEN")
{
  updateDebugStatus("Recognized already installed", [UIColor orangeColor]);
  throw "Installed";
}

if (title === "GET" || title === "INSTALL" || title === null)  //GET: have not downloaded on this account; null: already downloaded
{
  updateDebugStatus("Pressing button", [UIColor cyanColor]);
  [button sendActionsForControlEvents:(1 << 17)]
}

updateDebugStatus("Pressed button", null);
throw "Pressed button";


