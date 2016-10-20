// Assumes you're on "App and iTunes Stores" screen
// iOS 9 only

var ssc = findOrThrowViewController(null, true, classMatcher('StoreSettingsController'), 'Could not find StoreSettingsController');

[ssc _signOut];

throwSuccess('Signed out')
