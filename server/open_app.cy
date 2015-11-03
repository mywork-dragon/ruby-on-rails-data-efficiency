offerViews = choose(SKUIOfferView)
offerView = null

found = false

for each (var anOfferView in offerViews)
{
  if (anOfferView.superview != null)
  {
    offerViewSubviews = anOfferView.subviews
    if (offerViewSubviews.length > 0)
    {
      button = offerViewSubviews[0]
      if (button.title != null && button.title.toString() === "OPEN")
      {
        found = true
        break
      }
    }
  }
}

if(!found)
{
  throw "Could not find OPEN button"
}

throw "Completed"