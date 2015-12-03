offerViews = choose(SKUIOfferView);
offerView = null;
button = null;

found = false;

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

for each (var anOfferView in offerViews)
{
  if (anOfferView.superview != null)
  {
    offerViewSubviews = anOfferView.subviews;
    if (offerViewSubviews.length > 0)
    {
      button = offerViewSubviews[0]
      if (button.title != null && button.title.toString() === "OPEN")
      {
        found = true;
        break;
      }
    }
  }
}

if(!found)
{
  updateDebugStatus("Waiting for download", [UIColor yellowColor]);
  throw "Could not find OPEN button";
}

if (!button)
{
  updateDebugStatus("Could not find button", [UIColor redColor]);
  throw "Cannot locate button";
}

updateDebugStatus("Finished download", null);
throw "Completed";