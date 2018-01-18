export function formatAppAdData (data) {
  return Object.values(data)[0];
}

export function formatAppCreatives (data) {
  const result = Object.assign({}, data);
  const results = Object.values(data.results);
  result.results = results.length ? results[0].creatives : [];
  return result;
}

export function addAdIds (ads) {
  if (ads) {
    for (let i = 0; i < ads.length; i++) {
      const ad = ads[i];
      ad.id = i;
    }
  }
  return ads;
}
