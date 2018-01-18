export function createRequestTypes(base) {
  const res = [];
  ['REQUEST', 'SUCCESS', 'FAILURE'].forEach((type) => {
    res.push(`${base}_${type}`);
  });
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
