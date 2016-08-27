var tableView = findOrThrow(null, true, classMatcher('UITableView'), 'Could not find App and iTunes Stores table');

var indexPath = [NSIndexPath indexPathForRow:0 inSection:1];

var delegate = tableView.delegate;

[delegate tableView:tableView didSelectRowAtIndexPath:indexPath];