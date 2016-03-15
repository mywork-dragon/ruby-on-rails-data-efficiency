var tabBar = first([UIApp keyWindow], classMatcher('FBTabBar'));

if (tabBar == null) {
	throw "Error: Could not find tab bar";
}

var delegate = [tabBar delegate];

if (delegate == null) {
	throw "Error: Could not find tab bar delegate";
}

var items = tabBar.items;

if (items.length != 5) {
	throw "Error: expected 5 tab bar items";
}

var more = items[4]; // tab bar items have a guaranteed order

[delegate tabBar:tabBar didSelectItem:more];

throw "Success: Pressed More";

