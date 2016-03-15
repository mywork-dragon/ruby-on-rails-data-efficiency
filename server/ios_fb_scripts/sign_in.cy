var form = first(UIApp.keyWindow, classMatcher('FBAuthUsernamePasswordContentView'));

if (form == null) {
	throw 'Could not find form';
}

var fields = select(form, classMatcher('UITextField'));

if (fields.length != 2) {
	throw 'Expected 2 entry fields. Found ' + fields.length;
}


// get user field - u. it's not hte other one
// get password field - p. the text by default is 'password'. 
// get button: find button label where text = 'Log in'. Get it's parent 

// enable button
// b.enabled = YES

// after filling in. send action 1<<6





// Get the 'FBTabBar' using first
// get the 'More' options
// bar.items where item.title.toString() == 'More'
// [bar.delegate tabBar:bar didSelectItem:more]


// table = first(UIApp.keyWindow, classMatcher('UITableView'))
// visual scroll to the bottom
// delegate = table.delegate.viewController // this is weird...I know
// [delegate tableView:table didSelectRowAtIndexPath[NSIndexPath indexPathForRow:0 inSection:4]]


// on iOS 8, it opens the app store normally and you can play around with it
// You can find a UINavigationBar. Inside, there are multiple UINavigationButtons
// Not sure how to find the one that is more "left" than the other
// Once you do, you can send (1<<6) to it

// iOS 9 might open a shake window




