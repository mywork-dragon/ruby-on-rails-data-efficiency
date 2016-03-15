var collection = findOrThrow(null, true, classMatcher('PUCollectionView'), 'Could not get collection');

var sections = [collection numberOfSections];

if (sections != 1) {
    throwError('Expecting 1 section. Found ' + sections);
}

var items = [collection numberOfItemsInSection:0];

if (items == 0) {
    throwError('No photos to select');
}

throwSuccess('Photos to delete: ' + items);