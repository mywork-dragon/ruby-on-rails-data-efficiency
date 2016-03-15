var feed = getFeed(),
	section = getCollectionSection(),
	itemsCount = [feed numberOfItemsInSection:section];

throw JSON.stringify({
	'section': section,
	'itemsCount': itemsCount
});