var shake = [UIApp keyWindow];

if (!classMatcher('FBShakeWindow')(shake)) {
    throwError('Shake window is not visible');
}

var nav = findOrThrow(shake, true, classMatcher('FBNavigationBar'), 'Could not find navigation bar');

var buttons = select(nav, classMatcher('UIButton'));

if (buttons.length < 1) {
    throwError('Expected at least one button in navigation bar. Found ' + buttons.length);
}

var buttonsOrdered = buttons.sort(function(a, b) {
    var a_coordinates = getScreenCoordinates(a),
        b_coordinates = getScreenCoordinates(b);

    return a_coordinates.x - b_coordinates.x;
});

var left = buttonsOrdered[0];

// verify that this is correct...should be in the upper left hand corner

var coordinates = getScreenCoordinates(left);
if (coordinates == null) {
    throwError('Could not get back button coordinates');
}

if (coordinates.x > 50 || coordinates.y > 50) {
    throwError('Back button coordinates are incorrect. They are ' + coordinates.x + ', ' + coordinates.y);
}

[left sendActionsForControlEvents:(1<<6)];

throwSuccess('Pressed Back');