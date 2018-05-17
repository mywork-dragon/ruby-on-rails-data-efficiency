import _ from 'lodash';

export function formatCategories (categories) {
  const result = {};

  categories.forEach((category) => {
    if (!result[category.id]) {
      category.id = category.id.toString();
      result[category.id] = category;
    } else {
      result[category.id] = Object.assign({}, result[category.id], category);
    }

    if (category.parent) {
      if (!result[category.parent.id] || !result[category.parent.id].subCategories) {
        result[category.parent.id] = Object.assign({}, result[category.parent.id], { subCategories: [] });
      }
      result[category.parent.id].subCategories.push(category);
    }
  });

  return result;
}

export function formatHeadquarterData (data) {
  const result = {
    cities: {},
    states: {},
    countries: {},
  };

  data.forEach((x) => {
    const cityKey = _.compact([x.city, x.state_code, x.country_code]).join('_');
    const stateKey = _.compact([x.state_code, x.country_code]).join('_');

    if (x.city && !result.cities[cityKey]) {
      result.cities[cityKey] = {
        code: x.city,
        name: _.compact([x.city, x.state, x.country]).join(', '),
        parents: { country_code: x.country_code, state_code: x.state_code },
      };
    }

    if (x.state_code && x.state && !result.states[stateKey]) {
      result.states[stateKey] = {
        code: x.state_code,
        name: _.compact([x.state, x.country]).join(', '),
        parents: { country_code: x.country_code },
      };
    }

    if (x.country_code && x.country && !result.countries[x.country_code]) {
      result.countries[x.country_code] = {
        code: x.country_code,
        name: x.country,
      };
    }
  });

  return result;
}
