$(document).ready(function(){

  var percentFinished = 0;
  
  progress(percentFinished, $("#progressBar"));
  
  var samplingInterval = 100; //ms
  var totalTime = 2;  //s
  
  var percentInterval = samplingInterval/(totalTime*10.0);
  console.log("percentInterval: " + percentInterval);
  
  $("#progressBar").hide();
  
  $("#app-form").submit(function(event){
    console.log("submit pressed");
    
    $("#progressBar").show();
    
    $("#show-signals-button").prop('disabled', true);
    $('#app-signals').html("")
    
    percentFinished = 0;
    progress(percentFinished, $("#progressBar"));
    
    interval = setInterval(function(){
      percentFinished += percentInterval;
      
      if(percentFinished >= 100)
      {
        clearInterval(interval);
        
        $("#show-signals-button").prop('disabled', false);
      }
      else
      {
        progress(percentFinished, $("#progressBar"));
      }
    }, samplingInterval);
    
    var data = {
      "url": $("#app-url-tag").val()
    };

    $.ajax({

      url: "/app_info_get_signals",
      data: data,

      success: function(data, response) {
        var services = data.services;
        
        clearInterval(interval);
        percentFinished = 100;
        progress(percentFinished, $("#progressBar"));
        $("#show-signals-button").prop('disabled', false);
        
        var servicesLength = services.length;
        
        if(servicesLength == 0)
        {
          $('#app-signals').html("<div><h3>No signals found.</h3></div>")
        }
        else
        {
          var list = "<ul>";
        
          for (var i = 0; i < servicesLength; i++) {
            list += "<li>" + services[i] + "</li>";
          }
        
          list += "</ul>"

          $('#app-signals').html("<div><ul>" + list + "</ul></div>")
        }
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