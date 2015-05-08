var mixpanelAnalyticsEventTooltip = function(tooltip) {
  mixpanel.track('Tooltip Viewed',
    {'tooltip': tooltip}
  );
};
