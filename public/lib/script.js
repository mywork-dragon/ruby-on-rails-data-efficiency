$(document).ready(function() {
    // $('[data-toggle="tooltip"]').tooltip()
    $(function () {
        $('[data-toggle="tooltip"]').tooltip()
        $('[data-toggle="popover"]').popover()
    })

    $('#app-select').ddslick({
        'width': '100%',
        onSelected: function(data){
            $("html, body").animate({ scrollTop: 0 }, "slow");
        }   
    });
    $('.livescan').on('click', function() {
        window.location = '/apps/ios/' +  $('.dd-selected-value').val()
    })

    $('a.app-sdks').on('click', function() {
        $('#sdkModal .modal-title, #sdkModal .modal-body').html('')
        var appId = $(this).data('id')
        var platform = $(this).data('platform')
        $.ajax({
          url: '/apps/' + platform + '/' + appId + '.js'
        });
    })

    $('a[data-featherlight]').hover(function() {
        var img = $(this).find('img')
        $('<i class="fa fa-search-plus fa-lg"></i>').css({
            'top': img.height()/2,
            'left': img.width()/2
        }).appendTo($(this))
    }, function() {
        $(this).find('i.fa').remove()
    })

    if ($('.app-sdks.show-modal').length) {
        $('#progressModal').modal('show')
        var progress = 0;
        function moveProgress() {
            // add progress between 10 and 30%
            var newProgress = Math.floor(Math.random() * (40 - 30 + 1)) + 30
            progress = Math.min(progress + newProgress, 100)
            if (progress >= 100) {
                clearInterval(timer)
                $('.app-sdks').css('visibility', 'visible');
                $('#progressModal').modal('hide')
            }
            $('.progress-bar').width(progress + '%').html(progress + '%')
        }
        var timer = setInterval(moveProgress, '2000')
    }

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

    $('.mighty-report #submit-email-form').submit(function(event) {
        var x = $('.mighty-report #submit-email-form')[0]["email"].value
        if (x.includes("@gmail.com")) {
            alert("Please input your work email.");
            return false;
        }
    });

});



