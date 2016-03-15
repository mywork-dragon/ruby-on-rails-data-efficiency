var nav = findOrThrow(null, true, classMatcher('UINavigationBar'), 'Could not find navigation bar');

var buttons = select(nav, classMatcher('UINavigationButton'));

if (buttons.length != 2) {
    throwError('Expected to find 2 nav buttons. Found: ' + buttons.length);
}

// The one we want is on the "left". Find it using coordinates
var max_x = -1,
    max_index = -1,
    coordinates = null;

for (var i = 0; i < buttons.length; i++) {
    coordinates = getScreenCoordinates(buttons[i]);

    if (coordinates == null) {
        throwError('Could not get nav bar button coordinates');
    }

    if (coordinates.x > max_x) {
        max_index = i;
        max_x = coordinates.x;
    }
}

var min_index = max_index == 0 ? 1 : 0,
    button = buttons[min_index];

[button sendActionsForControlEvents:(1<<6)];

throwSuccess('Pressed Share');