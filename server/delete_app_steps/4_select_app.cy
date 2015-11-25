function findTable() {
	var available = null;
	var all = choose(UITableView);
	for each (var t in all) {
		if (t.used != true) {
			if (available != null) { throw "Found multiple table options"; }
			available = t;
		}
	}

	if (available == null) { throw "Could not find table"; }
	return available;
}

// Select App
var table = findTable(),
	delegate = table.delegate;


var cells = choose(PSUsageBundleCell),
	target = null;

for each (var cell in cells) {
	if (cell.text == "%s") {
		if (target != null) { throw "Found multiple delete app options"; }
		target = cell;
	}
}

if (target == null) { throw "Could not find app to delete"; }
[delegate tableView:table didSelectRowAtIndexPath:[table indexPathForCell:target]]

table.used = true