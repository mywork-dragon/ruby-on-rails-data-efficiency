var sw = findOrThrow(null, true, classMatcher('UISwitch'), 'Could not find UISwitch');

if (sw.on == YES){
  [sw setOn:NO animated:YES];
  var cell = sw.superview;
  [cell controlChanged:sw]; 
}
