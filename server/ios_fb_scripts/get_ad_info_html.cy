var webView = findOrThrow(null, true, classMatcher('FBWKWebView'), 'Could not find web view');

var url = [webView currentLocationURL];

if (!url) {
    throwError('Could not get web view\'s url');
}

var html = [NSString stringWithContentsOfURL:url encoding:4 error:null];

if (!html) {
    throwError('Could not get HTML');
}

throw html.toString();