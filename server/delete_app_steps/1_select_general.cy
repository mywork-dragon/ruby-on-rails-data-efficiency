function findTable() {
	var available = null;
	var all = choose(UITableView);
	for each (var t in all) {
		if (t.used != true) {
			if (available != null) { throw "Found multiple table options"}
			available = t;
		}
	}

	if (available == null) { throw "Could not find table"}
	return available;
}

// Select General
var table = findTable(),
	delegate = table.delegate;

[delegate tableView:table didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];

table.used = true