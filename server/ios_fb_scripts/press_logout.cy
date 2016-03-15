var table = first([UIApp keyWindow], classMatcher('UITableView')),
	row = 0,
	section = 4;

var indexPath = [NSIndexPath indexPathForRow:row inSection:section];

if (table == null) {
	throw "Error: Could not find table";
}

var delegate = [table delegate];

if (delegate == null) {
	throw "Error: Could not find table's delegate";
}

var viewController = [delegate viewController];

if (viewController == null) {
	throw "Error: Could not find delegate's viewController";
}

[viewController tableView:table didSelectRowAtIndexPath:indexPath];

throw "Success: Pressed Logout";