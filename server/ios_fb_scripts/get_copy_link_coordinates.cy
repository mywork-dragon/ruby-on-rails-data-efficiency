var copy_link_label = first([UIApp keyWindow], function(el) {

    if (classMatcher('UILabel')(el) || classMatcher('_UIActivityGroupActivityCellTitleLabel')(el)) {
        if (el.text && el.text.toString().match(/Copy Link/)) {
            return true;
        }
    }

    return false;
});


if (copy_link_label == null) {
    throw "Error: Could not find copy link label cell";
}

throwScreenCoordinates(copy_link_label);

