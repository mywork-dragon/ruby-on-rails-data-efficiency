var feed = getFeed(),
    index = $1,
    section = $0;

var indexPath = [NSIndexPath indexPathForItem:index inSection:section];

var item = [feed cellForItemAtIndexPath:indexPath];

// get button by size
var buttons = select(item, classMatcher('UIButton'));

var valid = buttons.filter(function(b) {
    var size = b.frame.size;

    if (size && size.width == 38 && size.height == 50 && isWithinScreenCoordinates(b)) {
        return true;
    }
    return false;
})

// going to temporarily press all the buttons
var button;
for (var i = 0; i < valid.length; i++) {
    button = valid[i];
    [button sendActionsForControlEvents:(1<<6)];
}

throwSuccess('Pressed buttons')

if (valid.length != 1) {
    throwError('Expected 1 valid button. Found ' + valid.length + ' out of ' + buttons.length);
}

// var button = valid[0];
// [button sendActionsForControlEvents:(1<<6)];

// throwSuccess('Pressed button');




// ========================================================================
// // could be in top header
// var topHeader = findOrThrow(item, true, classMatcher('FBRichTextWithEntityTruncationView'), 'Could not find Suggested Apps header');

// var topHeader = first(item, classMatcher('FBRichTextWithEntityTruncationView'));

// var buttons = select(topHeader, classMatcher('UIButton'));

// var button = buttons[0];

// if (topHeader && buttons.length > 0) {
//     if (buttons.length > 1) {
//         throwError('Expected 1 button in header. Found ' + buttons.length);
//     }

//     button = buttons[0];
// } else {
//     // fall back to the app subview
// }

// var labels = select(item, function(el) {
//     if (classMatcher('UIButtonLabel')(el) && [el text] == null && [el layer] != null) {
//         return true;
//     }

//     return false;
// });

// var conforming = labels.filter(function(l) {
//     var c = getScreenCoordinates(l);
//     if (c == null) {
//         return false;
//     }
//     if (c.y > 0 && c.y < 150 && c.x > 0 && c.x < feed.frame.size.width) {
//         return true;
//     }

//     return false;
// });

// if (conforming.length != 1) {
//     throwError('Expected 1 ad options button. Found ' + conforming.length + ' out of available ' + labels.length);
// }

// var label = conforming[0];

// var button = findOrThrow(label, false, classMatcher('UIButton'), "Could not find the label's button");