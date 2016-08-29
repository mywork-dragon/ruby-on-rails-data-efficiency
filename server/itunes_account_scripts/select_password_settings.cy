// Assume starting on "App and iTunes Stores" screen and just signed in
var tableView = findOrThrow(null, true, classMatcher('UITableView'), 'Could not find App and iTunes Stores table');

var indexPath = [NSIndexPath indexPathForRow:1 inSection:0];

var delegate = tableView.delegate;

[delegate tableView:tableView didSelectRowAtIndexPath:indexPath];