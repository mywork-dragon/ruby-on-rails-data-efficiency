import httpClient from './httpClient';

const url = 'http://mightyquery-927305443.us-east-1.elb.amazonaws.com';

const ExploreService = (client = httpClient) => ({
  getResultsByQueryId: (id, page) => (
    ExploreService().getQueryResultInfo(id)
      .then(response => (
        ExploreService().getResultsByResultId(response.data.query_result_id, page)
          .then(res => ({
            data: res.data,
            resultsCount: response.data.number_results,
          }))
      ))
  ),
  getQueryId: params => (
    client.put(`${url}/query`, params)
  ),
  getQueryParams: id => (
    client.get(`${url}/query/${id}`)
  ),
  getQueryResultInfo: id => (
    client.put(`${url}/query_result/${id}`)
  ),
  getResultsByResultId: (id, page) => (
    client.get(`${url}/query_result/${id}/pages/${page}?formatter=json_list`)
  ),
});

export default ExploreService;
