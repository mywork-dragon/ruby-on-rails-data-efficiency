var page = require('webpage').create();
page.open('https://angel.co/companies', function() {
  page.includeJs("http://code.jquery.com/jquery-1.11.1.min.js", function() {
    
    console.log("JQuery loaded")
    
    page.evaluate(function() {
      // $("button.more").click()
      
      // console.log("evaluate")
      
      var moreLength = 0;
      
      do {
        
        
        
      } while (moreLength != 0); 
      
      var more = $(".more");
      more.click();
      
      // console.log("moreButton: " + moreButton)
    });
    
    console.log("moreButton: " + moreButton)
    
    console.log("will exit")
    phantom.exit()
  });
});