$(document).ready(function() {

  var options = {
    url: function (input) {
      if (input.length >= 2) {
        return `welcome/search_apps?query=${input}`;
      }
    },
    getValue: "name",
    theme: 'round',
    template: {
      type: 'custom',
      method: function (value, item) {
        return (
          `<div class="app-result-img-container">` +
          `<i class="app-result-platform fa fa-${item.platform === 'ios' ? 'apple' : 'android'} fa-lg fa-fw" />` +
          `<img class="app-result-icon" src="${item.icon}" />` +
          `</div>` +
          `<div class="app-result-name-container">` +
          `<div class="app-result-name">${item.name}</div>` +
          `<div class="app-result-publisher">${item.publisher}</div>` +
          `</div>`
        );
      }
    },
    list: {
      onChooseEvent: function () {
        const item = $("#app-search").getSelectedItemData();
        const url = `/a/${item.platform === 'ios' ? 'ios' : 'google-play'}/${item.app_identifier}?utm_source=search_box`;
        document.location.href = url;
      }
    }
  };

  $("#app-search").easyAutocomplete(options);
})
