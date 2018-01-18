import httpClient from './httpClient';

const ListService = (client = httpClient) => ({
  getLists: () => (
    client.get('/api/list/get_lists')
  ),
  getList: (listId, page) => (
    client.get('/api/list/get_list', { params: { listId, page } })
  ),
  createList: listName => (
    client.get('/api/list/create_new', { params: { listName } })
  ),
  deleteList: listId => (
    client.put('/api/list/delete', { listId })
  ),
  addToList: (listId, apps) => (
    client.put('/api/list/add', { listId, apps })
  ),
  deleteFromList: (listId, apps) => (
    client.put('/api/list/delete_items', { listId, apps })
  ),
  exportToCsv: listId => (
    client.get('/api/list/export_to_csv', { params: { listId } })
  ),
});

export default ListService;
