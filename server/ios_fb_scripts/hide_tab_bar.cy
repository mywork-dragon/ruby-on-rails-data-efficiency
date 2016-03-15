var tabBar = first([UIApp keyWindow], classMatcher('FBTabBar'))

if (tabBar == null) {
	throw "Error: Could not find tab bar"
}

[tabBar setAlpha:0]

throw "Success"