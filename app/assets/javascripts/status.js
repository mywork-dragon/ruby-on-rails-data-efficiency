$(document).ready(function(){
	$('.carousel').slick({
    dots: true,
    slidesToShow: 1
    // adaptiveHeight: true
	});
});

$('#myDropdown').ddslick({
    onSelected: function(selectedData){
        //callback function: do something with selectedData;
    }   
});