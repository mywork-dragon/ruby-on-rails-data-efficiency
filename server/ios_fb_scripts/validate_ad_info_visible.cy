var shake = [UIApp keyWindow];

if (!classMatcher('FBShakeWindow')(shake)) {
    throwError('Shake window is not visible');
}

var nav = findOrThrow(shake, true, classMatcher('FBNavigationBar'), 'Could not find navigation bar');

var adLabel = findOrThrow(nav, true, classAndTextMatcher('UILabel', /Why am i seeing this ad/i), 'Could not find Ad Preferences header');

throwSuccess('Validated');
