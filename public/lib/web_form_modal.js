$(document).ready(function() {
    $('#webFormModal').on('show.bs.modal', function(e) {
       var buttonId = e.relatedTarget.dataset.buttonid;
       $("#button-id-field").val(buttonId)
    })

    let params = (new URL(document.location)).searchParams;
    let utm_source = params.get("utm_source");
    let utm_medium = params.get("utm_medium");
    let utm_campaign = params.get("utm_campaign");

    if (utm_source) {
      document.cookie = `utm_source=${utm_source}`;
      document.cookie = `utm_medium=${utm_medium}`;
      document.cookie = `utm_campaign=${utm_campaign}`;
    }
    (function() {
        'use strict';
        window.addEventListener('load', function() {
            // Fetch all the forms we want to apply custom Bootstrap validation styles to
            var forms = document.getElementsByClassName('needs-validation');
            // Loop over them and prevent submission
            var validation = Array.prototype.filter.call(forms, function(form) {
                form.addEventListener('submit', function(event) {
                    if (form.checkValidity() === false) {
                        event.preventDefault();
                        event.stopPropagation();
                    }
                    form.classList.add('was-validated');
                }, false);
            });
        }, false);
    })();
});
