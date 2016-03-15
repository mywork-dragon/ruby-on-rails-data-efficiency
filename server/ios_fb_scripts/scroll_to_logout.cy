var table = first([UIApp keyWindow], classMatcher('UITableView')),
	row = 0,
	section = 4;

if (table == null) {
	throw "Error: Could not find table"
}

var sections = [table numberOfSections];

if (sections != 5) {
	throw "Error: Expected 5 sections. Found: " + sections;
}

var rows = [table numberOfRowsInSection:section];

if (rows != 1) {
	throw "Error: Expected 1 row. Found: " + rows;
}

var indexPath = [NSIndexPath indexPathForRow:row inSection:section];

[table scrollToRowAtIndexPath:indexPath atScrollPosition: 1<<0 animated:YES];

throw "Success: Scrolled"