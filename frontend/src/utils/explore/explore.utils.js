import { convertToTableSort } from './queryBuilder.utils';

export function formatResults (data, params) {
  const result = {};
  result.results = Object.values(data.pages)[0].map(x => extractPublisher(x)).map(x => mockDataEnhancer(x)); // TODO: remove eventually
  result.pageNum = parseInt(Object.keys(data.pages)[0]);
  result.pageSize = params.page_settings.page_size;
  result.resultsCount = result.results.length * 2;
  result.sort = convertToTableSort(params.sort.fields);
  result.resultType = params.select.object;

  return result;
}

export function extractPublisher (app) {
  const result = Object.assign({}, app);
  delete result.publisher_name;
  delete result.publisher_id;
  result.publisher = {
    id: app.publisher_id,
    name: app.publisher_name,
    platform: app.platform,
  };

  return result;
}

function mockDataEnhancer (app) {
  return {
    ...app,
    type: app.platform === 'ios' ? 'IosApp' : 'AndroidApp',
  };
}
