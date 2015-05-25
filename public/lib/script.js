$(document).ready(function() {

    /* Roll-over image functionality for team section */
    $('.mainProfileImage')
        .mouseover(
            function () {
                $(this).parent().find('.mainProfileImage').hide();
                $(this).parent().find('.secondProfileImage').show();
            });
    $('.secondProfileImage')
        .mouseout(
            function () {
                $(this).parent().find('.mainProfileImage').show();
                $(this).parent().find('.secondProfileImage').hide();
            });

    /* Calls BxJQuery Slider */
    $('.bxslider').bxSlider({
        'auto': true,
        'pause': 4000
    });

});