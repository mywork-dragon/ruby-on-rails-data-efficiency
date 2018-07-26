import mixpanel from 'mixpanel-browser';

const AppRankingsMixpanelService = () => ({
  trackChartLoad: params => mixpanel.track('App Rankings Loaded', params),
  trackFilterChange: params => mixpanel.track('App Ranking Filter Changed', params),
  trackTableSort: params => mixpanel.track('App Rankings Table Sorted', params),
});

export default AppRankingsMixpanelService;
