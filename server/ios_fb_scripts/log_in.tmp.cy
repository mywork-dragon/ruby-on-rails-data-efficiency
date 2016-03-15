var username = '$0',
	password = '$1';

var container = first([UIApp keyWindow], classMatcher('FBAuthUsernamePasswordContentView'));

if (container == null) {
	throw "Error: Could not find auth container";
}

// password one will say Password...the other will either say Username or whatever username came before it
var textFieldLabels = select(container, classMatcher('UITextFieldLabel'));

if (textFieldLabels.length != 2) {
	throw "Error: Expected 2 text fields. Found " + textFieldLabels.length;
}


var label,
	field,
	content;

for (var i = 0; i < textFieldLabels.length; i++) {
	label = textFieldLabels[i];
	field = parent(label, classMatcher('UITextField'))

	if (field == null) {
		throw "Error: Could not find text field";
	}

	if (label.text && label.text.toString().match(/Password/i)) {
		content = password;
	} else {
		content = username;
	}

	field.text = content
}

var log_in_label = first([UIApp keyWindow], function(el) {
	if (classMatcher('UIButtonLabel')(el) && el.text && el.text.toString().match(/Log/i)) {
		return true;
	}

	return false;
});

if (log_in_label == null) {
	throw "Error: Could not find log in button label";
}

var log_in_button = parent(log_in_label, classMatcher('UIButton'));

if (log_in_button == null) {
	throw "Error: Could not find log in button";
}

[log_in_button sendActionsForControlEvents:(1<<6)]

throw "Pressed Log in"

