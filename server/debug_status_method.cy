// displays the text with the specified color. If ui_color is null, shows green
// ui_color should be a UIColor object
function updateDebugStatus(text, ui_color) {

  function CGPointMake(x, y) { return {x:x, y:y}; }
  function CGSizeMake(w, h) { return {width:w, height:h}; }
  function CGRectMake(x, y, w, h) { return {origin:CGPointMake(x,y), size:CGSizeMake(w, h)}; }

  var w = UIApp.windows[0];

  w.rootViewController.view;

  var label = [UILabel new];
  label.frame = CGRectMake(0, 0, 320, 50);
  label.text = text;
  label.backgroundColor = ui_color || [UIColor greenColor];

  [w.rootViewController.view addSubview:label];
}