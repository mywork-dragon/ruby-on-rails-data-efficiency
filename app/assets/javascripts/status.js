// $(document).ready(function(){
//   // console.log("document ready");
//   $('.carousel').slick({
//     dots: true,
//     slidesToShow: 1
//     // adaptiveHeight: true
//   });
// });

$(document).ready(function(){
  console.log("ready")
  $('#theDropdown').ddslick({
    width: 200,
    onSelected: function(selectedData){
      console.log("Selected");
    }
  });
});

