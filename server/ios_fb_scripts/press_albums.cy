var tabBar = findOrThrow(null, true, classMatcher('UITabBar'), 'Could not find tab bar');

var items = tabBar.items;

if (items.length != 3) {
    throwError("expected 3 tab bar items. Found " + items.length);
}

var albumRegex = /Albums/;
var albumLabel = findOrThrow(tabBar, true, classAndTextMatcher('UITabBarButtonLabel', albumRegex), 'Could not find album label');

var button = findOrThrow(albumLabel, false, classMatcher('UITabBarButton'), 'Could not find album button');

[button sendActionsForControlEvents:(1<<6)];

throwSuccess("Pressed Albums");