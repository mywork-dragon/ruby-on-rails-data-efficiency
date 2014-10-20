// $(document).ready(function(){
//   console.log("ready")
//   $(function() {
//     var progressbar = $( "#progressbar-2" );
//     $( "#progressbar-2" ).progressbar({
//       value: 30,
//       max:300
//     });
//
//     function progress() {
//       var val = progressbar.progressbar( "value" ) || 0;
//       progressbar.progressbar( "value", val + 1 );
//       if ( val < 99 ) {
//        setTimeout( progress, 100 );
//       }
//     }
//     setTimeout( progress, 3000 );
//   });
// });
//

$(document).ready(function(){

  var percentFinished = 0;
  
  progress(percentFinished, $("#progressBar"));
  
  var samplingInterval = 500; //ms
  var totalTime = 10;  //s
  
  var percentInterval = samplingInterval/(totalTime*10.0);
  console.log("percentInterval: " + percentInterval);
  
  $("#services-form").submit(function(event){
    console.log("submit pressed");
    
    interval = setInterval(function(){
      percentFinished += percentInterval;
      
      progress(percentFinished, $("#progressBar"));
      
      if(percentFinished >= 100)
      {
        clearInterval(interval);
      }
    }, samplingInterval);
    
    var data = {
      "jq key": "jq value"
    };

    $.ajax({

      url: "/services",
      data: data,

      success: function(data, response) {
        var url = data.key;

        $('#servicesUsing').html("<div>" + url + "</div>")
      }

    })

    return false;
  });
});

function progress(percent, $element) {
    var progressBarWidth = percent * $element.width() / 100;
    $element.find('div').animate({ width: progressBarWidth }, 500).html(percent + "%&nbsp;");
}

