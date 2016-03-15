var transitionView = first([UIApp keyWindow], classMatcher('UITransitionView'));

if (!transitionView) {
	throw "Error: Could not find transition view";
}

var collection_wrapper = first(transitionView, classMatcher('UICollectionViewControllerWrapperView'));

if (!collection_wrapper) {
	throw "Error: Could not find collection view wrapper in transition view";
}

var collection = first(collection_wrapper, classMatcher('UICollectionView'));

if (!collection) {
	throw "Error: Could not find collection in wrapper";
}

var sections = [collection numberOfSections];

if ([collection numberOfSections] != 3) {
	throw "Error: Expected 3 sections in options menu. Found: " + sections;
}

// Assume it's the last section

var row = [collection cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:2]];

var subCollection = first(row, classMatcher('UICollectionView'));

if (!subCollection) {
	throw "Error: Could not find sub collection in row of options menu";
}

sections = [subCollection numberOfSections]
if ([subCollection numberOfSections] != 1) {
	throw "Error: Expected 1 section in row. Found: " + sections;
}

// Empty the pasteboard
var pasteboard = [UIPasteboard generalPasteboard];
pasteboard.string = @'';

// Assume it's the first one in the collection
var subDelegate = subCollection.delegate;
[subDelegate collectionView:subCollection didSelectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];

throw "Pressed Copy"