var collection = findOrThrow(null, true, classMatcher('PUCollectionView'), 'Could not get collection');

[collection scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:(1<<0) animated:YES];

throwSuccess('Scrolled');