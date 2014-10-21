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
  var totalTime = 13;  //s
  
  var percentInterval = samplingInterval/(totalTime*10.0);
  console.log("percentInterval: " + percentInterval);
  
  $("#services-form").submit(function(event){
    console.log("submit pressed");
    
    $("#servicesSubmitButton").prop('disabled', true);
    $('#servicesUsing').html("")
    
    percentFinished = 0;
    progress(percentFinished, $("#progressBar"));
    
    interval = setInterval(function(){
      percentFinished += percentInterval;
      
      if(percentFinished >= 100)
      {
        clearInterval(interval);
        
        $("#servicesSubmitButton").prop('disabled', false);
      }
      else
      {
        progress(percentFinished, $("#progressBar"));
      }
    }, samplingInterval);
    
    var data = {
      "url": $("#services-url-tag").val()
    };

    $.ajax({

      url: "/demo_services",
      data: data,

      success: function(data, response) {
        var services = data.services;
        
        var list = "<ul>";
        
        var servicesLength = services.length;
        for (var i = 0; i < servicesLength; i++) {
          list += "<li>" + services[i] + "</li>";
        }
        
        list += "</ul>"

        $('#servicesUsing').html("<div><ul>" + list + "</ul></div>")
      }

    })

    return false;
  });
});

function progress(percent, $element) {
    var progressBarWidth = percent * $element.width() / 100;
    // $element.find('div').animate({ width: progressBarWidth }, 500).html(percent + "%&nbsp;");
    
    $element.find('div').animate({ width: progressBarWidth }, 500);
}

