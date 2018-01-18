import axios from 'axios';
import { getToken } from './auth';

// TODO: i think this doesn't work if person is not already logged in.
// may need to ensure that shared httpClient always has token ready
const httpClient = axios.create({
  headers: { Authorization: getToken() },
});

export default httpClient;
