var auth_container = first([UIApp keyWindow], classMatcher('FBAuthUsernamePasswordContentView'));

if (auth_container) {
	throw "False: Not logged in";
}

var feed = getFeed();

if (feed) {
	throw "True: Logged In";
}

var alert_controller = first([UIApp keyWindow], classMatcher('_UIAlertControllerView'));

if (alert_controller) {
	throw "True: Log out alert still available"
}

throw "False: Unknown";