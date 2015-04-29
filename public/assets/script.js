$(document).ready(function() {
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
});