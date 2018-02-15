import httpClient from './httpClient';

const ExploreService = (client = httpClient) => ({
  requestResults: (params) => {
    const page = params.page_settings.page;
    delete params.page_settings.page; // TODO: hopefully this can be removed eventually
    return client.put(`http://mightyquery-927305443.us-east-1.elb.amazonaws.com/query/query_result/pages/${page}?formatter=json_list`, params);
  },
});

export default ExploreService;
