var c = [SBApplicationController sharedInstance];

var bundleId = [[NSString alloc] initWithUTF8String:"%s"]

if ([c applicationWithBundleIdentifier:bundleId] != null) {
	throw "Completed"
}
throw "Not available"