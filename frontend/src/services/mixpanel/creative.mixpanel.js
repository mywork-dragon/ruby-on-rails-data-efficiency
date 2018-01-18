import mixpanel from 'mixpanel-browser';

const CreativeMixpanelService = (id, platform, type) => ({
  trackCreativeClick: creative => mixpanel.track('Creative Clicked', {
    id,
    platform,
    pageType: type,
    format: creative.format,
    app_identifier: creative.app_identifier,
  }),
  trackCreativePageThrough: page => mixpanel.track('Creatives Paged Through', {
    id,
    platform,
    pageNum: page,
    pageType: type,
  }),
});

export default CreativeMixpanelService;
