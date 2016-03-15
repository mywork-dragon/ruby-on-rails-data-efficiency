var section = $0,
    index = $1,
    adIndex = $2;

var feed = getFeed(),
indexPath = [NSIndexPath indexPathForItem:index inSection:section];

var scroll = findOrThrow(item, true, classMatcher('FBHScrollComponentCollectionView'), 'Could not find scroll');

var items = [scroll numberOfItemsInSection:0]

if (adIndex >= items) {
  throwError('Only ' + items + ' ads in scroll. Cannot scroll to ' + adIndex);
}

[scroll scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:adIndex inSection:0] atScrollPosition:(1<<3) animated:YES]; // (1<<3) means left-aligned

throwSuccess('Scrolled Ad');