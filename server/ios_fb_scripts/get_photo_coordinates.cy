var collection = findOrThrow(null, true, classMatcher('PUCollectionView'), 'Could not get collection');

var MAX_ITEMS = 20; // only 20 fully visible at a time

var sections = [collection numberOfSections];

if (sections != 1) {
    throwError('Expecting 1 section. Found ' + sections);
}

var indexPaths = [collection indexPathsForVisibleItems];

var coordinates = [],
    c,
    path,
    frame,
    cell;

for (var i = 0; i < indexPaths.length; i++) {
    indexPath = indexPaths[i];
    cell = [collection cellForItemAtIndexPath:indexPath];
    frame = [cell frame];

    if (!cell) {
        throwError('Could not get cell for index: ' + [indexPath item]);
    }

    c = getScreenCoordinates(cell);

    if (!isWithinScreenCoordinates(cell)) {
        continue;
    }
    middle_x = c.x + (frame.size.width / 2);
    middle_y = c.y + (frame.size.height / 2);

    coordinates.push({
        x: middle_x,
        y: middle_y
    });
}

coordinates = coordinates.sort(function(a, b) {
    return a['y'] - b['y'];
});

if (coordinates.length > MAX_ITEMS) {
    coordinates.splice(MAX_ITEMS);
}

throw JSON.stringify(coordinates);