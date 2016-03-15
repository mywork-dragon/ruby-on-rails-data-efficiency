function find_ad_in_feed() {
	var feed = getFeed();

	var section = getCollectionSection(),
		itemsCount = [feed numberOfItemsInSection:section];

	throw JSON.stringify({
		'section': section,
		'itemsCount': itemsCount
	})

	// [feed scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:2 inSection:section]];
	for (var i = 0; i < itemsCount; i++) {
		[feed scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:section] atScrollPosition: 1<<0 animated:YES];
		start = Date.now();
		while (Date.now() - start < 1000) {
			x = 5;
		}
	}

	return itemsCount;
}

find_ad_in_feed();