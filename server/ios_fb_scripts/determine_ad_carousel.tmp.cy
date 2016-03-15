var feed = getFeed(),
    section = $0,
    index = $1;

var indexPath = [NSIndexPath indexPathForItem:index inSection:section];

var item = [feed cellForItemAtIndexPath:indexPath];

var scroll = findOrThrow(item, true, classMatcher('FBHScrollComponentCollectionView'), 'Could not find scroll');

var sections = [scroll numberOfSections];

if (sections != 1) {
    throwError('Should only have 1 section');
}

var dots = select(item, classMatcher('FBHScrollPaginatorDot'));

if (dots.length < 1) {
    throwError('Could not find paginator dots');
}

var onScreenDots = dots.filter(isWithinScreenCoordinates);

if (dots.length <= 0) {
    throwError('No dots available on screen');
}

var count = [scroll numberOfItemsInSection:0];

throwSuccess('Found scroll with items count: ' + count);