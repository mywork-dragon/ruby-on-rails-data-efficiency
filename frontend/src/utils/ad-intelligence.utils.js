export function sortNetworks (overallNetworks, itemNetworks) {
  const itemIds = itemNetworks.map(network => network.id);
  return overallNetworks.filter(network => itemIds.includes(network.id));
}

export function getAltUrl (url) {
  return url.replace(/^https/i, 'http');
}
