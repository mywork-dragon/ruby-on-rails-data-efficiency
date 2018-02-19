import httpClient from './httpClient';

const url = 'http://mightyquery-927305443.us-east-1.elb.amazonaws.com';

const ExploreService = (client = httpClient) => ({
  requestResults: (params, page) => (
    ExploreService().requestQueryId(params)
      .then(response => ExploreService().requestQueryResultInfo(response.data.query_id))
      .then(res => (
        ExploreService().requestResultsById(res.data.query_result_id, page)
          .then(result => ({
            data: result.data,
            resultsCount: res.data.number_results,
          }))
      ))
  ),
  requestQueryId: params => (
    client.put(`${url}/query`, params)
  ),
  requestQueryResultInfo: id => (
    client.put(`${url}/query_result/${id}`)
  ),
  requestResultsById: (id, page) => (
    client.get(`${url}/query_result/${id}/pages/${page}?formatter=json_list`)
  ),
});

export default ExploreService;
