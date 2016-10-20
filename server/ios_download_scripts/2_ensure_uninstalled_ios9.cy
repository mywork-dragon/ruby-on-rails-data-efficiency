var c = [SBApplicationController sharedInstance];

var bundleIds = "%s".split(",").map(function(text) {
	return [[NSString alloc] initWithUTF8String:text];
});

for (var i = 0; i < bundleIds.length; i++) {
	if ([c applicationWithBundleIdentifier:bundleIds[i]] != null) {
		throw "app still installed: " + bundleIds[i].toString();
	}
}
// free them afterwards?
throw "all gone";
