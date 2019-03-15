function getParameterByName(name, url) {
    if (!url) url = window.location.href;
    name = name.replace(/[\[\]]/g, "\\$&");
    var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
        results = regex.exec(url);
    if (!results) return null;
    if (!results[2]) return '';
    return decodeURIComponent(results[2].replace(/\+/g, " "));
}

function render_plot() {
  if (window.fastest_growing_sdk_data) {
    var data = window.fastest_growing_sdk_data[window.fastest_growing_sdk_data_mode];
    if (!window.fastest_growing_sdk_data_force_all_sdks) {
    data = _.filter(data, function(x) {
      return _.any(x['tags'], 
        function(y) {
          return window.fastest_growing_sdk_data_tag_filters[y];
        })
      });
    }

    var layout = {
      title: "MightySignal Install Base",
      height: 600,
      showlegend: true,
      xaxis: {
        title: 'Month',
        titlefont: {
          family: 'Courier New, monospace',
          size: 18,
          color: '#7f7f7f'
        }
      },
      yaxis: {
        title: 'Install Base',
        titlefont: {
          family: 'Courier New, monospace',
          size: 18,
          color: '#7f7f7f'
        }
      }
    };
    Plotly.newPlot('fastest-growing-sdk-chart', data, layout, {displayModeBar: true});
  } else {
    console.log("Render plot called without data");
  }
  hide_non_active_tag_selectors();
}

function hide_non_active_tag_selectors() {
  //Hide all
  for (var key in window.fastest_growing_sdk_data_visible_tags['all']) {
    var tag = window.fastest_growing_sdk_data_visible_tags['all'][key];
    window.fastest_growing_sdk_data_tag_to_element[tag].hide(0);
  }
  //Show all that should be shown.
  for (var key in window.fastest_growing_sdk_data_visible_tags[window.fastest_growing_sdk_data_mode]) {
    var tag = window.fastest_growing_sdk_data_visible_tags[window.fastest_growing_sdk_data_mode][key];
    window.fastest_growing_sdk_data_tag_to_element[tag].show(0);
  }
}

function sdk_tag_toggle(button, should_update) {
  var tag = button.attr('data-sdk-tag');
  if (tag == 'All') {
    window.fastest_growing_sdk_data_force_all_sdks = true;
    // Enable all tags.
    for (var key in window.fastest_growing_sdk_data_tag_filters) {
      window.fastest_growing_sdk_data_tag_filters[key] = true;
    }
    for (var key in window.fastest_growing_sdk_data_tag_to_element) {
      window.fastest_growing_sdk_data_tag_to_element[key].addClass('btn-primary');
    }
    return;
  }

  all_selected = _.all(window.fastest_growing_sdk_data_tag_filters, function(x) {return x; });
  if (all_selected) {
    // Clear all selects.
    window.fastest_growing_sdk_data_force_all_sdks = false;
    for (var key in window.fastest_growing_sdk_data_tag_filters) {
      window.fastest_growing_sdk_data_tag_filters[key] = false;
    }
    for (var key in window.fastest_growing_sdk_data_tag_to_element) {
      window.fastest_growing_sdk_data_tag_to_element[key].removeClass('btn-primary');
    }
    // Reselect just the one selected button.
    window.fastest_growing_sdk_data_tag_filters[tag] = true;
    button.addClass('btn-primary');
  } else {
    window.fastest_growing_sdk_data_tag_filters[tag] = ! window.fastest_growing_sdk_data_tag_filters[tag];
    if (window.fastest_growing_sdk_data_tag_filters[tag]) {
      button.addClass('btn-primary');
    } else {
      button.removeClass('btn-primary');
    }
  }
  if (should_update) {
   update_url();
  }
}

function update_url() {
  if (history.pushState) {
    var active_tags = _.filter(Object.keys(window.fastest_growing_sdk_data_tag_filters), function(x) {return window.fastest_growing_sdk_data_tag_filters[x]; });
    var newurl = window.location.protocol + "//" + window.location.host + window.location.pathname
      + '?mode=' + window.fastest_growing_sdk_data_mode
      + '&tags=' + active_tags.join(',')
      + '&view=' + window.fastest_growing_sdk_view
      ;
    window.history.pushState({path:newurl},'',newurl);
  }
}


function create_tag_selector() {
  var data = window.fastest_growing_sdk_data;
  window.fastest_growing_sdk_data_tag_filters = {};
  window.fastest_growing_sdk_data_force_all_sdks = false;
  window.fastest_growing_sdk_data_visible_tags = {};
  var absolute_tags = Array.from(new Set(_.flatten(_.map(data['absolute'], function(x) { return x['tags']}))));
  var relative_tags = Array.from(new Set(_.flatten(_.map(data['relative'], function(x) { return x['tags']}))));
  var tags = _.union(relative_tags, absolute_tags);
  window.fastest_growing_sdk_data_visible_tags['all'] = tags;
  window.fastest_growing_sdk_data_visible_tags['absolute'] = ['Backend', 'App Performance Management', 'Monetization', 'App Platform', 'Analytics'];
  window.fastest_growing_sdk_data_visible_tags['relative'] = ['App Performance Management', 'Monetization'];
  window.fastest_growing_sdk_data_tag_to_element = {};

  
  var tag_group = $('#sdk-tag-button-group');
  tag_group.html('');
  // Create sdk tag selector elements

  //ALL TAG
  var button = $('<button data-sdk-tag="All" class="btn btn-default btn-block sdk-tag-button">All</button>');
  tag_group.append(button);
  window.fastest_growing_sdk_data_tag_to_element['All'] = button;
  window.fastest_growing_sdk_data_tag_filters['All'] = false;

  // Other tags
  tags.forEach(function(tag) {
    var button = $('<button data-sdk-tag="'+tag+'" class="btn btn-default btn-block sdk-tag-button"></button>');
    button.html(tag);
    tag_group.append(button);
    window.fastest_growing_sdk_data_tag_to_element[tag] = button;
    window.fastest_growing_sdk_data_tag_filters[tag] = false;
  });


  $('.sdk-tag-button').click(function () {
    sdk_tag_toggle($(this));  
    render_plot();
  });

  //Enable those elements specified via query string or use default.
  var enabled_tags_qs = getParameterByName('tags');
  var enabled_tags = [];
  if (enabled_tags_qs == 'all' ) {
    enabled_tags = ['All'];
  } else if (enabled_tags_qs) {
    enabled_tags = enabled_tags_qs.split(',');
  } else {
    // Default to all tags selected.
    enabled_tags = ['All']
  }

  enabled_tags.forEach (function (tag) {
    sdk_tag_toggle(window.fastest_growing_sdk_data_tag_to_element[tag], false)
  });
}

function fasted_growing_sdk_chart_set_absolute() {
  window.fastest_growing_sdk_data_mode = 'absolute';
  $('#fastest-growing-sdk-chart-abs').addClass('btn-primary');
  $('#fastest-growing-sdk-chart-relative').removeClass('btn-primary');
  render_plot();
  render_table();
}

function fasted_growing_sdk_chart_set_relative() {
    window.fastest_growing_sdk_data_mode = 'relative';
    $('#fastest-growing-sdk-chart-relative').addClass('btn-primary');
    $('#fastest-growing-sdk-chart-abs').removeClass('btn-primary');
    render_plot();
    render_table();
}

function render_table() {
  var dataSet = _.map(window.fastest_growing_sdk_data[window.fastest_growing_sdk_data_mode],
    function(x, index) { return [
      index + 1,
      x['name'],
      '<a target="_blank" href="'+x['sdk_website']+'">'+x['sdk_website']+'</a>',
      x['tags'].join()]; }
    );
  $('#fastest-growing-sdk-table').DataTable( {
      data: dataSet,
      destroy: true,
      columns: [
          { title: "Rank" },
          { title: "Name" },
          { title: "Website" },
          { title: "Categories" }
      ]
  } );
}

function fastest_growing_sdks_set_table_view(should_update) {
  window.fastest_growing_sdk_view = 'table';
  $('#fastest-growing-sdk-table-switch').addClass('btn-primary');
  $('#fastest-growing-sdk-chart-switch').removeClass('btn-primary');
  $('#fastest-growing-sdk-chart-container').hide(0);
  $('#fastest-growing-sdk-table-container').show(0);
  if (should_update) {
    update_url();
  }
} 

function fastest_growing_sdks_set_chart_view(should_update) {
  window.fastest_growing_sdk_view = 'chart';
  $('#fastest-growing-sdk-chart-switch').addClass('btn-primary');
  $('#fastest-growing-sdk-table-switch').removeClass('btn-primary');
  $('#fastest-growing-sdk-table-container').hide(0);
  $('#fastest-growing-sdk-chart-container').show(0);
  if (should_update) {
    update_url();
    render_plot();
  }
} 


$(document).ready(function() {

  // Chart vs Table toggles
  $('#fastest-growing-sdk-chart-switch').click(fastest_growing_sdks_set_chart_view);
  $('#fastest-growing-sdk-table-switch').click(fastest_growing_sdks_set_table_view);

  // Absolute vs relative toggles.
  $('#fastest-growing-sdk-chart-abs').click(fasted_growing_sdk_chart_set_absolute);
  $('#fastest-growing-sdk-chart-relative').click(fasted_growing_sdk_chart_set_relative);

  $.get("fastest-growing-android-sdks", function(data, success) {
    window.fastest_growing_sdk_data = {};
    if (getParameterByName('mode') == 'relative') {
      window.fastest_growing_sdk_data_mode = 'relative';
      $('#fastest-growing-sdk-chart-relative').addClass('btn-primary');
      $('#fastest-growing-sdk-chart-abs').removeClass('btn-primary');
    } else {
      window.fastest_growing_sdk_data_mode = 'absolute';
    }

    for (var key in data) {
      var chart = data[key];
      window.fastest_growing_sdk_data[key] = chart;
      chart.sort(function(a, b) {
        if (a['sort_by'] > b['sort_by']) {
          return -1;
        } else if (a['sort_by'] < b['sort_by']) {
          return 1;
        } else {
          return 0;
        }
      });

      for (var key in chart) {
         sdk_trace = chart[key];

        sdk_trace['mode'] = "lines";
        sdk_trace['type'] = "scatter";
      }
    }
    if (getParameterByName('view') == 'table') {
      fastest_growing_sdks_set_table_view(false);
    } else {
      fastest_growing_sdks_set_chart_view(false);
    }
    create_tag_selector();
    render_plot();
    render_table();


  });

});
