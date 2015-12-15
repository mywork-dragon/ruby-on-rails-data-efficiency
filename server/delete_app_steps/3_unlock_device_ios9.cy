if ([[UIWindow keyWindow].rootViewController.className isEqualToString:@"SBMainScreenAlertWindowViewController"]) {
  //unlock
  [[objc_getClass("SBBacklightController") sharedInstance] turnOnScreenFullyWithBacklightSource:0];
  [[objc_getClass("SBLockScreenManager") sharedInstance] unlockUIFromSource:0 withOptions:nil];
}

throw "Something happened bad"