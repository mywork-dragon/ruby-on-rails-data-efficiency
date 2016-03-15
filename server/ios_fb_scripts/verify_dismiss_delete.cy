var transitionView = findOrThrow(null, true, classMatcher('UITransitionView'), 'Could not find transition view');

var label = findOrThrow(transitionView, true, classAndTextMatcher('UILabel', /Delete [\d]*\s?Photo/), 'Could not find label to delete');