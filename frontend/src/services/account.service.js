import httpClient from './httpClient';

const AccountService = (client = httpClient) => ({
  getAdNetworks: () => (
    client.get('/api/ad_intelligence/v2/ad_sources')
  ),
});

export default AccountService;
