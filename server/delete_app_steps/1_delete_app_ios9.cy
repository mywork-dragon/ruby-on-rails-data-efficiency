function appWithBundleId(bundleId) {

  var apps = choose(SBApplication);

  for each (var app in apps) {
    if (app.bundleIdentifier == bundleId) {
      return app;
    }
  }

  throw "Could not find app";

  return false;
}

var c = [SBApplicationController sharedInstance];

var a = appWithBundleId("%s");

[c uninstallApplication:a];