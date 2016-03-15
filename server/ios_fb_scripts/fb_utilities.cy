function CGPointMake(x, y) { return {x:x, y:y}; }
function CGSizeMake(w, h) { return {width:w, height:h}; }
function CGRectMake(x, y, w, h) { return {origin:CGPointMake(x,y), size:CGSizeMake(w, h)}; }

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
  return null;
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

// get the button if it exists. Returns null otherwise
function getInstallButton_old(container) {
  var button_regex = /Install|Download|(Shop Now)|(Play Game)/i

  var button_label = first(container, function(el) {
      if (classMatcher('UIButtonLabel')(el) && el.text && el.text.toString().match(button_regex)) {
          return true;
      }
      return false;
  });

  if (!button_label) {
      return null;
  }

  var button = parent(button_label, classMatcher('UIButton'));

  return button;
}

// get the button if it exists. Returns null otherwise
function getInstallButton(container) {
  var button_regex = /Install|Download|(Shop Now)|(Play Game)|(Learn More)/i;

  var button_label = select(container, function(el) {
      if (classMatcher('UIButtonLabel')(el) && el.text && el.text.toString().match(button_regex)) {
          return true;
      }
      return false;
  });

  if (button_label.length == 0) {
      return null;
  }

  var valid_labels = button_label.filter(function(label) {
    var button = parent(label, classMatcher('UIButton'));

    if (!button) {
      return false;
    }

    if ([button isHidden]) {
      return false;
    }

    if (!isWithinScreenCoordinates(label)) {
      return false;
    }

    return true;
  });

  if (valid_labels.length == 0) {
    return null;
  }

  if (valid_labels.length > 1) {
    throwError('Found multiple valid install buttons');
  }

  var button = findOrThrow(valid_labels[0], false, classMatcher('UIButton'), 'Could not find label\'s parent button. 2nd');

  return button;
}

function getCollectionSection() {
  var feed = getFeed();

  // get the correct section
  var cells = select(feed, function(el) {
    return el.superclass && el.superclass.toString() == 'UICollectionViewCell';
  });

  var cell = null,
    j = 0;

  while (cell == null && j < cells.length) {
    if ([feed indexPathForCell:cells[j]] && cells[j].class.toString() == 'FBComponentHostingCollectionViewCell') {
      cell = cells[j];
    }
    j++;
  }

  if (cell == null) {
    throw "Could not find cell in collection";
  }

  var path = [feed indexPathForCell:cell];

  return path.section;
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

function itemScroller(index, section, position) {
  var feed = getFeed(),
    indexPath = [NSIndexPath indexPathForItem:index inSection:section];

  [feed scrollToItemAtIndexPath:indexPath atScrollPosition:position animated:YES];
}

function selectAlbumType(regex, typeName) {
  var table = findOrThrow(null, true, classMatcher('UITableView'), 'Could not find table');

  // multiple sections...may vary by device
  var text = findOrThrow(table, true, classAndTextMatcher('UITextFieldLabel', regex), 'Could not find text for ' + typeName);

  var cell = findOrThrow(text, false, classMatcher('PUAlbumListTableViewCell'), 'Could not find table view cell for ' + typeName);

  var indexPath = [table indexPathForCell:cell];

  if (!indexPath) {
      throwError("Could not get index path for album cell for " + typeName);
  }

  var delegate = [table delegate];

  if (!delegate) {
      throwError("Could not find table view's delegate");
  }

  [delegate tableView:table didSelectRowAtIndexPath:indexPath];

  throwSuccess("Pressed " + typeName);
}

function isWithinScreenCoordinates(el) {
  var app = [UIApp keyWindow],
    coordinates = getScreenCoordinates(el);

    if (coordinates && coordinates.x >= 0 && coordinates.x < app.frame.size.width && coordinates.y >= 0 && coordinates.y < app.frame.size.height) {
      return true;
    }

    return false;
}