function appsWithBundleId(bundleIds) {

  var apps = choose(SBApplication);
  var result = []

  for (var i = 0; i < apps.length; i++) {
  	if (bundleIds.indexOf(apps[i].bundleIdentifier.toString()) != -1) {
  		result.push(apps[i])
  	}
  }

  if (result.length == 0) {
  	throw "Could not find app"
  }
  return result;
}

var c = [SBApplicationController sharedInstance];

var ids = "%s";
var bundleIds = ids.split(",")

var apps = appsWithBundleId(bundleIds);

for (var i = 0; i < apps.length; i++) {
	[c uninstallApplication:apps[i]];	
}

