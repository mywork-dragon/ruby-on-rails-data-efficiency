var feed = getFeed(),
    index = $1,
    section = $0;

var indexPath = [NSIndexPath indexPathForItem:index inSection:section];

[feed reloadItemsAtIndexPaths:[indexPath] forDataSource:[feed dataSource]];

throw "Refreshed";