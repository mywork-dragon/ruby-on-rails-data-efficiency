var dimmingView = findOrThrow(null, true, classMatcher('FBDimmingView'), 'Could not find dimming view');

var options = findOrThrow(dimmingView, true, classMatcher('FBActionSheetContentView'), 'Could not find options sheet');

var label = findOrThrow(options, true, classAndTextMatcher('UILabel', /Why am I seeing this/i), "Could not find 'Why am I seeing this?' option");

var button = findOrThrow(label, false, classMatcher('FBActionSheetButton'), 'Could not find parent button');

[button sendActionsForControlEvents:(1<<6)];

throwSuccess('Pressed button');