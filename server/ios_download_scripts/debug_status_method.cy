// displays the text with the specified color. If ui_color is null, shows green
// ui_color should be a UIColor object
function updateDebugStatus(text, ui_color) {

  function CGPointMake(x, y) { return {0:x, 1:y}; }
  function CGSizeMake(w, h) { return {0:w, 1:h}; }
  function CGRectMake(x, y, w, h) { return {0:CGPointMake(x,y), 1:CGSizeMake(w, h)}; }

  var w = UIApp.keyWindow

  label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
  label.text = text;
  label.backgroundColor = ui_color || [UIColor greenColor];

  [w.rootViewController.view addSubview:label];
}
