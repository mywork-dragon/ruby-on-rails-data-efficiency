offerViews = choose(SKUIOfferView)
offerView = null

found = false

startTime = Date.now()


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
  throw "Could not find GET or cloud button"
}

offerViewSubviews = offerView.subviews
button = offerViewSubviews[0]

title = (button.title === null ? null : button.title.toString())

if (title === "GET" || title === null)  //GET: have not downloaded on this account; null: already downloaded
{
  [button sendActionsForControlEvents:(1 << 17)]
}
