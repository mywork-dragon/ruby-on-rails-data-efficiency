// Select App and iTunes Stores
// iOS 9 only

var tableView = findOrThrow(null, true, classMatcher('UITableView'), 'Could not find table');

var indexPath = [NSIndexPath indexPathForRow:1 inSection:3];

[tableView scrollToRowAtIndexPath:indexPath atScrollPosition:0 animated:YES];
var delegate = tableView.delegate;

[delegate tableView:tableView didSelectRowAtIndexPath:indexPath];

throwSuccess('Selected')
