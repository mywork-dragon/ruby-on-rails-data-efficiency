function getFeed() {
  var top = UIApp.keyWindow,
  subviews = [],
  backstop = 1000,
  views = null,
  v = null,
  j = 0,
  i = 0;

  subviews.push([top])

  while (i < backstop && subviews.length > 0) {
    views = subviews.shift()

    for (var j = 0; j < views.length; j++) {
      v = views[j];

      if (v.class && v.class.toString() == "FBFeedCollectionView") {
        // return i;
        return v;
      }

      if (v && v.subviews) {
        subviews = subviews.concat(v.subviews)
      }
    }
    i++;
  }
  return false;
};

function findParent(source, targetClass) {
  var current = source,
  i = 0;

  while (current != null) {
    current = current.superview;
    if (current.class.toString() == targetClass) {
      return current;
    }
  }

  return null;
}


function findLabelsByText(str) {
  var labels = choose(UIButtonLabel)
  return labels.filter(function(x) {if ([x isHidden] == false && x.text && x.text.toString() == str) {return x.text;}});
}

function findComponentByText(str) {
  var labels = choose(FBRichTextComponentView)
  return labels.filter(function(x) {if ([x isHidden] == false && x.text && x.text.toString() == str) {return x.text;}});
}