import moment from 'moment';

export default function validateFormState (form) {
  let result = { ...form };
  result = convertDatesToMoments(result);

  return result;
}

function convertDatesToMoments (form) {
  const result = { ...form };

  const { filters } = result;

  filters.sdks.filters.forEach((filter) => {
    filter.dates = filter.dates.map(x => moment(x));
  });

  if (filters.releaseDate) {
    filters.releaseDate.value.dates = filters.releaseDate.value.dates.map(x => moment(x));
  }

  if (filters.adNetworks) {
    filters.adNetworks.value.firstSeenDate = moment(filters.adNetworks.value.firstSeenDate);
    filters.adNetworks.value.lastSeenDate = moment(filters.adNetworks.value.lastSeenDate);
  }

  return result;
}
