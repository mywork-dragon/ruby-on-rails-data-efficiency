import moment from 'moment';
import getDisplayText from './displayText.utils';

export default function validateFormState (form, currentVersion) {
  let result = { ...form };
  result = convertDatesToMoments(result);
  result = updateDisplayTexts(result);

  return {
    form: result,
    shouldUpdate: form.version !== currentVersion,
  };
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

function updateDisplayTexts (form) {
  const result = { ...form };

  Object.keys(form.filters).forEach((key) => {
    if (form.filters[key].displayTest) {
      form.filters[key].displayText = getDisplayText(key, form.filters[key].value);
    } else if (key === 'sdks') {
      form.filters.sdks.filters.forEach((filter) => {
        filter.displayText = getDisplayText('sdk', filter);
      });
    }
  });

  return result;
}
