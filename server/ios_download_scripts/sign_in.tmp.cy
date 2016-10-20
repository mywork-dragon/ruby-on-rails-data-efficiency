var appleId = @"$0", password = @"$1";

var ssc = findOrThrowViewController(null, true, classMatcher('StoreSettingsController'), 'Could not find StoreSettingsController');

[ssc _setAppleID:appleId];
[ssc _setPassword:password];

var alertView = [[UIAlertView alloc] init];
alertView.title = @"title";
alertView.message = @"message";
alertView.delegate = nil;
alertView.cancelButtonTitle = @"title";
alertView.otherButtonTitles = @[@"Sign In"];
alertView.alertViewStyle = 3;

var appleIdTextField = [alertView textFieldAtIndex:0];
var passwordTextField = [alertView textFieldAtIndex:1];

appleIdTextField.text = appleId;
passwordTextField.text = password;

[ssc alertView:alertView didDismissWithButtonIndex:1];
[ssc _signIn];

throwSuccess('Signed in')
