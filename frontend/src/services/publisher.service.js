import httpClient from './httpClient';

const PublisherService = (client = httpClient) => ({
  getPublisherInfo: (id, platform) => (
    client.get(`/api/get_${platform}_developer`, { params: { id } })
  ),
  getSdkInfo: (id, platform) => (
    client.get(`/api/${platform}_sdks_exist`, { params: { publisherId: id } })
  ),
  getAdIntelInfo: (id, platform) => (
    client.get('/api/ad_intelligence/v2/publisher_summary.json', { params: { publisher_id: id, platform } })
  ),
  getCreatives: (id, platform, {
    pageNum = 1,
    pageSize = 8,
    networks = [],
    formats = [],
  }) => (
    client.get('/api/ad_intelligence/v2/publisher_creatives.json', {
      params: {
        platform,
        publisher_id: id,
        pageNum,
        pageSize,
        sourceIds: JSON.stringify(networks),
        formats: JSON.stringify(formats),
      },
    })
  ),
  getContactsExportCsv: domains => (
    client.post('/api/contacts/start_export_to_csv', { domains })
  ),
});

export default PublisherService;
