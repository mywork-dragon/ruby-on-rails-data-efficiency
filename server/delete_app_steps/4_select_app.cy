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

function selectAppToDelete(table) {
	var section_number = 1;
	var start_index = 0;
	var end_index = [table numberOfRowsInSection:section_number] || 0;
	var cell = null;
	var result = null;
	var known_texts = ["Mail", "Calendars & Reminders", "Health", "Safari", "iBooks", "Podcasts", "Photos & Camera"];

	while (start_index < end_index && !result) {
		path = [NSIndexPath indexPathForRow:start_index inSection:section_number]
		cell = [table cellForRowAtIndexPath:path];
		text = cell.text.toString();
		if (known_texts.indexOf(text) == -1) {
			result = path;
		}
		start_index++;
	}

	return result;
}

// Select Top App
var table = findTable(),
	delegate = table.delegate;

indexPath = selectAppToDelete(table);
[delegate tableView:table didSelectRowAtIndexPath:indexPath];

table.used = true

// old way to select by name
// var cells = choose(PSUsageBundleCell),
// 	target = null;

// for each (var cell in cells) {
// 	if (cell.text == "%s") {
// 		if (target != null) { throw "Found multiple delete app options"; }
// 		target = cell;
// 	}
// }

// if (target == null) { throw "Could not find app to delete"; }
// [delegate tableView:table didSelectRowAtIndexPath:[table indexPathForCell:target]]