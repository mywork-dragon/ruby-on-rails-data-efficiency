function appsWithBundleId(bundleIds) {

  var c = [SBApplicationController sharedInstance];
  var result = [];
  var app = null;

  for (var i = 0; i < bundleIds.length; i++) {
    app = [c applicationWithBundleIdentifier:bundleIds[i]]
    if (app != nil) {
      result.push(app);
    }
  }

  if (result.length == 0) {
  	throw "Could not find app";
  }
  return result;
}

var c = [SBApplicationController sharedInstance];

var bundleIds = "%s".split(",").map(function(text) {
  return [[NSString alloc] initWithUTF8String:text];
});

// free them afterwards?

var apps = appsWithBundleId(bundleIds);

for (var i = 0; i < apps.length; i++) {
	[c uninstallApplication:apps[i]];	
}
