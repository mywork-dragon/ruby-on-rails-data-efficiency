export const REQUEST = 'REQUEST'
export const SUCCESS = 'SUCCESS'
export const FAILURE = 'FAILURE'

export function createRequestTypes(base, name) {
  const root = name ? `${name}/${base}` : `${base}`;
  const res = {};
  [REQUEST, SUCCESS, FAILURE].forEach(type => res[type] = `${root}_${type}`);
  return res;
}

export function buildBaseRequestTypes (name, types) {
  const res = {};
  types.forEach(type => res[type] = createRequestTypes(type, name));
  return res;
}

export function namespaceActions(base, types) {
  const res = {};
  types.forEach((type) => {
    res[type] = `${base}/${type}`;
  });
  return res;
}

export function action(type, payload) {
  return payload ? { type, payload } : { type };
}
