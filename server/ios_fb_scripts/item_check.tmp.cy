// use single quotes in this file for templating reasons
var feed = getFeed(),
    index = $1,
    section = $0;

var appTextClasses = [
    'FBRichTextView',
    'FBRichTextComponentView'
];

var indexPath = [NSIndexPath indexPathForItem:index inSection:section];

var item = [feed cellForItemAtIndexPath:indexPath];

var prefix = 's' + section + ' i' + index + ': ';

if (item == null) {
    throwError(prefix + 'No item available')
}

var suggestedText = first(item, function(el) {
    var className = '';
    if (el.class) {
        className = el.class.toString();
    }

    if (appTextClasses.indexOf(className) == -1) {
        return false;
    }

    if (el.text && (/Suggested App/i).exec(el.text.toString())) {
        return true;
    }

    return false;
});

if (suggestedText == null) {
    throwError(prefix + 'Not an ad')
}

// also check to see if the label and button exists

var button = getInstallButton(item);

if (!button) {
    throwError(prefix + 'Could not find button');
}

throwSuccess('Found one!');