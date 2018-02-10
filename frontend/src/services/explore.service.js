import { exploreResults } from 'utils/mocks/mock-data.utils';
import httpClient from './httpClient';

const ExploreService = (client = httpClient) => ({
  requestResults: params => (
    exploreResults(params)
  ),
});

export default ExploreService;
