// $(document).ready(function(){
//   // console.log("document ready");
//   $('.carousel').slick({
//     dots: true,
//     slidesToShow: 1
//     // adaptiveHeight: true
//   });
// });

$(document).ready(function(){
  selectText: "Choose a customer to pretend to be.",
  $('#companies-dropdown').ddslick({
    width: 300,
    onSelected: function(selectedData){
      console.log("Selected");
    }
  });
});

