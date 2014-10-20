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

  
  progress(65, $("#progressBar"))
  
  $("#services-form").submit(function(event){
    console.log("submit pressed");
    return false;
  });
});

function progress(percent, $element) {
    var progressBarWidth = percent * $element.width() / 100;
    $element.find('div').animate({ width: progressBarWidth }, 500).html(percent + "%&nbsp;");
}

// var data = {
//   "jq key": "jq value"
// };
//
// $.ajax({
//
//   url: "/services",
//   data: data,
//
//   success: function(data, response) {
//     var url = data.key;
//
//     $('#servicesUsing').html("<div>" + url + "</div>")
//   }
//
// })