$(document).ready(function(){
  console.log("ready")
  $(function() {
    var progressbar = $( "#progressbar-2" );
    $( "#progressbar-2" ).progressbar({
      value: 30,
      max:300
    });

    function progress() {
      var val = progressbar.progressbar( "value" ) || 0;
      progressbar.progressbar( "value", val + 1 );
      if ( val < 99 ) {
       setTimeout( progress, 100 );
      }
    }
    setTimeout( progress, 3000 );
  });
});

