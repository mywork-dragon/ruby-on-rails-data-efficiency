function CGPointMake(x, y) { return {x:x, y:y}; }
function CGSizeMake(w, h) { return {width:w, height:h}; }
function CGRectMake(x, y, w, h) { return {origin:CGPointMake(x,y), size:CGSizeMake(w, h)}; }

function select(source, match_fn) {
  if (!source) {
    source = [UIApp keyWindow];
  }

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
    return el && el.class && el.class.toString() == className;
  }
}

function classAndTextMatcher(className, regex) {
  return function(el) {
    if (classMatcher(className)(el) && el.text && el.text.toString().match(regex)) {
      return true;
    }
    return false;
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

  return null;
}

function parent(source, match_fn) {
  var current = source;

  while (current != null) {
    current = current.superview;

    if (match_fn(current)) {
      return current;
    }
  }

  return null;
}

function getScreenCoordinates(el) {
  var superview = el.superview;

  var coordinates = [superview convertPoint:el.frame.origin toView:nil];

  return coordinates;
};

function throwScreenCoordinates(el) {
  var coordinates = getScreenCoordinates(el);

  throw JSON.stringify({
    'x': coordinates.x,
    'y': coordinates.y
  });
}

function isWithinScreenCoordinates(el) {
  var app = [UIApp keyWindow],
    coordinates = getScreenCoordinates(el);

    if (coordinates && coordinates.x >= 0 && coordinates.x < app.frame.size.width && coordinates.y >= 0 && coordinates.y < app.frame.size.height) {
      return true;
    }

    return false;
}

function throwError(text) {
  throw "Error: " + text;
}

function throwSuccess(text) {
  throw "Success: " + text;
}

// if root is null, just uses the keyWindow
function findOrThrow(root, descending, condition, error_text) {
  if (!root) {
    root = [UIApp keyWindow];
  }

  var element;

  if (descending) {
    element = first(root, condition);
  } else {
    element = parent(root, condition);
  }

  if (!element) {
    throwError(error_text);
  }

  return element;
}

// new, by Jason
// if root is null, just uses the [UIApplication sharedApplication].keyWindow.rootViewController
function findOrThrowViewController(root, descending, condition, error_text) {
  if (!root) {
    root = [UIApplication sharedApplication].keyWindow.rootViewController;
  }

  var element;

  if (descending) {
    element = firstViewController(root, condition);
  } else {
    element = parentViewController(root, condition);
  }

  if (!element) {
    throwError(error_text);
  }

  return element;
}

//new, by Jason
function firstViewController(source, match_fn) {
  var current = null,
    childViewControllers = [],
    queue = [],
    v;

  queue.push(source);

  while (queue.length > 0) {
    current = queue.shift()
    if (current && current.childViewControllers) {
      childViewControllers = current.childViewControllers

      for (var i = 0; i < childViewControllers.length; i++) {
        v = childViewControllers[i];
        if (match_fn(v)) {
          return v;
        } else if (v) {
          queue.push(v);
        }
      }
    }
  }

  return null;
}

// new, by Jason
function parentViewController(source, match_fn) {
  var current = source;

  while (current != null) {
    current = current.parentViewController;

    if (match_fn(current)) {
      return current;
    }
  }

  return null;
}