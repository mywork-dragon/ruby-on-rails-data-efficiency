// $(document).ready(function(){
//   // console.log("document ready");
//   $('.carousel').slick({
//     dots: true,
//     slidesToShow: 1
//     // adaptiveHeight: true
//   });
// });

$('#theDropdown').ddslick({
  onSelected: function(selectedData){
    console.log("Selected");
  }
});