offerViews = choose(SKUIOfferView)
offerView = null

found = false

startTime = Date.now()

function isDownloading(b) {
  var start = Date.now()
  downloading = false
  // will poll for 2 seconds
  while (Date.now() - start < 2000 && !downloading) {
    var contents = b.layer.contents.toString()
    // More than 1 buffers indicates activity 
    if (contents.match(/buffer/g).length > 1) {
      downloading = true;
    }
  }

  return downloading
}


while(Date.now() - startTime < 10000 && !found)
{
  for each (var anOfferView in offerViews)
  {
    if (anOfferView.superview != null)
    {
      offerView = anOfferView
      found = true
      break
    }
  }
}

if (!found)
{
  throw "Could not find button";
}

offerViewSubviews = offerView.subviews
button = offerViewSubviews[0]

if (isDownloading(button)) {
  throw "Downloading";
}

title = (button.title === null ? null : button.title.toString())

if (title === "OPEN")
{
  throw "Installed"
}

if (title === "GET" || title === "INSTALL" || title === null)  //GET: have not downloaded on this account; null: already downloaded
{
  [button sendActionsForControlEvents:(1 << 17)]
}

throw "Pressed button"


