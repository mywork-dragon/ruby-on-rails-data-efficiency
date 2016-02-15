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

function select(source, match_fn) {
  var current = null,
    subviews = [],
    found = [],
    queue = [],
    v;

  queue.push(source);

  while (queue.length > 0) {
    current = queue.shift()
    if (current && current.subviews) {
      subviews = current.subviews

      for (var i = 0; i < subviews.length; i++) {
        v = subviews[i];
        if (match_fn(v)) {
          found.push(v)
        } else if (v) {
          queue.push(v)
        }
      }
    }
  }

  return found;
}

function classMatcher(className) {
  return function(el) {
    return el.class && el.class.toString() == className;
  }
}

function first(source, match_fn) {
  var current = null,
    subviews = [],
    queue = [],
    v;

  queue.push(source);

  while (queue.length > 0) {
    current = queue.shift()
    if (current && current.subviews) {
      subviews = current.subviews

      for (var i = 0; i < subviews.length; i++) {
        v = subviews[i];
        if (match_fn(v)) {
          return v;
        } else if (v) {
          queue.push(v)
        }
      }
    }
  }

  return nil
}

function select(source, targetClass) {
  var current = null,
    subviews = [],
    found = [],
    queue = source.subviews,
    v;

  while (queue.length > 0) {
    current = queue.shift()
    if (current) {
      subviews = current.subviews

      for (var i = 0; i < subviews.length; i++) {
        v = subviews[i];
        if (v.class && v.class.toString() == targetClass) {
          found.push(v)
        } else if (v) {
          queue.push(v)
        }
      }
    }
  }

  return found;
}

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