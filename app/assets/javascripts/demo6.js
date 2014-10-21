$(document).ready(function(){
  $("select").change(function () {
    console.log("changed");
    var str = "";
    $("select option:selected").each(function() {
      str = $( this ).text();
    });
    
    $("#companies-using").html(str);
  }).change();
});