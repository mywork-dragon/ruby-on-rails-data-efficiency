import { exploreResults } from 'utils/mock-data.utils';
import httpClient from './httpClient';

const ExploreService = (client = httpClient) => ({
  requestResults: params => (
    exploreResults(params)
  ),
});

export default ExploreService;
