var nav = findOrThrow(null, true, classMatcher('UINavigationBar'), 'Could not find nav');

var button_label = findOrThrow(nav, true, classAndTextMatcher('UIButtonLabel', /Select/), 'Could not find button label');

var button = findOrThrow(button_label, false, classMatcher('UINavigationButton'), 'Could not find button');

[button sendActionsForControlEvents:(1<<6)];

throwSuccess('Pressed select mode')