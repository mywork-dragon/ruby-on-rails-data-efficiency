var clipboard = [UIPasteboard generalPasteboard]

if (clipboard.string == null) {
	throw "Error: nothing on the clipboard";
}

throw clipboard.string.toString();