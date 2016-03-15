var feed = getFeed(),
    index = $1,
    section = $0;

var indexPath = [NSIndexPath indexPathForItem:index inSection:section];

var item = [feed cellForItemAtIndexPath:indexPath];

var button = getInstallButton(item);

if (!button) {
	throw "Error: Could not find button";
}

[button sendActionsForControlEvents:(1<<6)];

throw "Pressed button";