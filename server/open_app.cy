offerViews = choose(SKUIOfferView);
offerView = null;
button = null;

found = false;

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