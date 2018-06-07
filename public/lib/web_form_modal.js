$(document).ready(function() {
    $('#webFormModal').on('show.bs.modal', function(e) {
       var buttonId = e.relatedTarget.dataset.buttonid;
       $("#button-id-field").val(buttonId)
    })

    let params = (new URL(document.location)).searchParams;
    let utm_source = params.get("utm_source");
    let utm_medium = params.get("utm_medium");
    let utm_campaign = params.get("utm_campaign");

    document.cookie = `utm_source=${utm_source}`;
    document.cookie = `utm_medium=${utm_medium}`;
    document.cookie = `utm_campaign=${utm_campaign}`;
});
