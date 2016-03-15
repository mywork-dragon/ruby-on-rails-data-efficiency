var logOutLabel = findOrThrow(null, true, function(el) {
    if (classMatcher('UILabel')(el) && el.text && el.text.toString().match(/^Log Out$/i)) {
        return true;
    }
    return false;
}, 'Could not find Log Out label');

throwScreenCoordinates(logOutLabel);