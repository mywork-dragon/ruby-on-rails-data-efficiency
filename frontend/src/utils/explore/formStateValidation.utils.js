import _ from 'lodash';
import moment from 'moment';
import { getNestedValue } from 'utils/format.utils';
import getDisplayText from './displayText.utils';

export default function validateFormState (form, currentVersion, iosCategories, androidCategories) {
  let result = { ...form };
  result = convertDatesToMoments(result);
  result = updateDisplayTexts(result);
  result = updateCategories(result, iosCategories, androidCategories);
  result.version = currentVersion;

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
    if (form.filters[key].displayText) {
      form.filters[key].displayText = getDisplayText(key, form.filters[key].value);
    } else if (key === 'sdks') {
      form.filters.sdks.filters.forEach((filter) => {
        filter.displayText = getDisplayText('sdk', filter);
      });
    }
  });

  return result;
}

export function updateCategories (form, iosCategories, androidCategories) {
  const result = _.cloneDeep(form);

  const iosFilterCategories = getNestedValue(['filters', 'iosCategories', 'value'], form) || [];
  const androidFilterCategories = getNestedValue(['filters', 'androidCategories', 'value'], form) || [];

  if (iosFilterCategories.length || androidFilterCategories.length) {
    const values = combineCategories(iosFilterCategories, androidFilterCategories, iosCategories, androidCategories);
    result.filters.categories = {
      value: values,
      panelKey: getNestedValue(['filters', 'iosCategories', 'panelKey'], result) || getNestedValue(['filters', 'androidCategories', 'panelKey'], result),
      displayText: getDisplayText('categories', values),
    };
    delete result.filters.iosCategories;
    delete result.filters.androidCategories;
  }

  const rankingsIosCategories = getNestedValue(['filters', 'rankings', 'value', 'iosCategories'], form) || [];
  const rankingsAndroidCategories = getNestedValue(['filters', 'rankings', 'value', 'androidCategories'], form) || [];

  if (rankingsIosCategories.length || rankingsAndroidCategories.length) {
    delete result.filters.rankings.value.iosCategories;
    delete result.filters.rankings.value.androidCategories;
    const values = combineCategories(rankingsIosCategories, rankingsAndroidCategories, iosCategories, androidCategories);
    result.filters.rankings.value.categories = values;
    result.filters.rankings.displayText = getDisplayText('rankings', result.filters.rankings.value);
  }

  return result;
}

function combineCategories (iosFilterCategories, androidFilterCategories, iosCategories, androidCategories) {
  const categories = {};
  iosFilterCategories.concat(androidFilterCategories).forEach((category) => {
    if (!categories[category.label]) {
      const iosCategory = iosCategories.find(x => x.name === category.label);
      const androidCategory = androidCategories.find(x => x.name === category.label);
      categories[category.label] = {
        value: category.label,
        label: category.label,
        ios: iosCategory ? iosCategory.id.toString() : null,
        android: androidCategory ? androidCategory.id : null,
      };
    }
  });

  return Object.values(categories);
}
