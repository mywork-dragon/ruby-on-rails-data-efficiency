import httpClient from './httpClient';

const AppService = (client = httpClient) => ({
  getAdIntelInfo: (id, platform) => (
    client.get('/api/ad_intelligence/v2/app_summaries.json', { params: { appIds: JSON.stringify([id]), platform } })
  ),
  getCreatives: (id, platform, { pageNum, pageSize, networks, formats }) => (
    client.get('/api/ad_intelligence/v2/creatives.json', {
      params: {
        platform,
        appIds: JSON.stringify([id]),
        pageNum,
        pageSize,
        sourceIds: JSON.stringify(networks),
        formats: JSON.stringify(formats),
      },
    })
  ),
});

export default AppService;
