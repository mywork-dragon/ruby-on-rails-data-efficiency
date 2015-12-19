// see if HTTP Request has failed
var wbs = choose(UIWebBrowserView);

if (wbs.length > 1) {
  throw "more than 1 web browser view";
}

var wb = wbs[0];

if (wb != null && wb.text.toString().match(/Service Unavailable/i) != null) {
  throw "ERROR: HTTP Failed";
}

// See if the content is available
var unavailableViews = choose(SKUIContentUnavailableView);
if (unavailableViews.length > 0) {
  throw "ERROR: Content Unavailable"
}

var cannotConnect = choose(_UIContentUnavailableView);
if (cannotConnect.length > 0) {
  throw "ERROR: Cannot connect to AppStore"
}

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

var offerViewSubviews = offerView.subviews;
var buttons = offerViewSubviews.filter(function(sv) {
  return sv.class.toString().match(/OfferButton/i)
})

if (buttons.length == 0) {
  throw "Could not find button";
}

if (buttons.length > 1) {
  throw "Found more than 1 button"
}

var button = buttons[0];

if (isDownloading(button)) {
  throw "Downloading";
}

title = (button.title === null ? null : button.title.toString());

if (title === "OPEN")
{
  updateDebugStatus("Recognized installed", [UIColor orangeColor]);
  throw "Installed";
}

if (title === "GET" || title === "INSTALL" || title === null)  //GET: have not downloaded on this account; null: already downloaded
{
  updateDebugStatus("Pressing button", [UIColor cyanColor]);
  [button sendActionsForControlEvents:(1 << 17)]
  throw "Pressed button";
}

throw "Undetermined"



