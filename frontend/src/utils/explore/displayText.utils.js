import moment from 'moment';
import _ from 'lodash';
import { capitalize, numberShorthand } from 'utils/format.utils';

function getDisplayText (parameter, value) {
  switch (parameter) {
    case 'iosCategories':
      return categoryText(value, 'ios');
    case 'androidCategories':
      return categoryText(value, 'android');
    case 'fortuneRank':
      return `Fortune Rank: ${value}`;
    case 'mobilePriority':
      return listText('Mobile Priority: ', value);
    case 'userBase':
      return listText('User Base: ', value);
    case 'sdk':
      return sdkText(value);
    case 'headquarters':
      return headquarterText(value);
    case 'availableCountries':
      return availableCountriesText(value);
    case 'price':
      return `Price: ${capitalize(value)}`;
    case 'inAppPurchases':
      return `In App Purchases: ${capitalize(value)}`;
    case 'creativeFormats':
      return creativeFormatsText(value);
    case 'adNetworks':
      return adNetworkText(value);
    case 'adNetworkCount':
      return rangeText('Advertising on', value);
    case 'ratingsCount':
      return rangeText('Ratings Count', value);
    case 'rating':
      return rangeText('Rating', value);
    case 'releaseDate':
      return `Released ${generateDateText(value.dateRange, value.dates)}`;
    case 'downloads':
      return rangeText('Downloads', value);
    case 'rankings':
      return rankingsText(value);
    default:
      return '';
  }
}

function listText(base, value) {
  return base + value.map(x => capitalize(x)).join(', ');
}

function categoryText (value, platform) {
  return `${capitalize(platform)} Categories: ${value.map(x => x.label).join(', ')}`;
}

function sdkText ({ eventType, sdks, dateRange, dates, installState }) {
  if (sdks.length === 0) {
    return '';
  }

  let eventTypeText;
  switch (eventType) {
    case 'install':
      eventTypeText = 'Installed';
      break;
    case 'uninstall':
      eventTypeText = 'Uninstalled';
      break;
    case 'never-seen':
      eventTypeText = 'Never Seen';
      break;
  }

  let installText;
  switch (installState) {
    case 'is-installed':
      installText = ' and Currently Installed';
      break;
    case 'is-not-installed':
      installText = ' and Currently Not Installed';
      break;
    default:
      installText = '';
  }
  const dateText = generateDateText(dateRange, dates);

  const requiresDate = ['install', 'uninstall'].includes(eventType);

  return `${sdks.map(x => `${x.name} (${capitalize(x.platform)})${x.sdks ? ` (${x.includedSdks.length} of ${x.sdks.length} SDKs)` : ''}`).join(', ')} ${eventTypeText} ${requiresDate ? dateText : ''}${eventType !== 'never-seen' ? installText : ''}`;
}

function headquarterText (countries) {
  return `Headquartered in ${countries.map(x => x.label).join(', ')}`;
}

function availableCountriesText ({ countries, condition }) {
  if (!countries || countries.length === 0) {
    return '';
  }

  let availableText;

  switch (condition) {
    case undefined:
    case 'only-available-in':
      availableText = 'Only Available in';
      break;
    case 'available-in':
      availableText = 'Available in';
      break;
    case 'not-available-in':
      availableText = 'Not Available in';
      break;
  }

  return `${availableText} ${countries.map(x => x.label).join(', ')}`;
}

function creativeFormatsText (value) {
  const map = {
    html_game: 'Playable',
    video: 'Video',
    other_formats: 'Other',
  };

  const formats = value.map(x => map[x]).join(', ');

  return `Creative Formats: ${formats}`;
}

function adNetworkText ({
  adNetworks,
  firstSeenDateRange,
  firstSeenDate,
  lastSeenDateRange,
  lastSeenDate,
}) {
  if (adNetworks.length === 0) {
    return null;
  }

  const networks = adNetworks.map(x => x.label).join(', ');

  const firstSeenText = `First Seen ${generateDateText(firstSeenDateRange, firstSeenDate)}`;
  const lastSeenText = `Last Seen ${generateDateText(lastSeenDateRange, lastSeenDate)}`;

  return `Advertising on ${networks}, ${firstSeenText}, ${lastSeenText}`;
}

function generateDateText (dateRange, dates) {
  let result;

  switch (dateRange) {
    case 'anytime':
      result = 'Anytime';
      break;
    case 'week':
      result = 'in the Last Week';
      break;
    case 'month':
      result = 'in the Last Month';
      break;
    case 'three-months':
      result = 'in the Last Three Months';
      break;
    case 'six-months':
      result = 'in the Last Six Months';
      break;
    case 'year':
      result = 'in the Last Year';
      break;
    case 'before-date':
      result = `Before ${moment(dates).format('L')}`;
      break;
    case 'after-date':
      result = `After ${moment(dates).format('L')}`;
      break;
    case 'custom':
      result = dates[0] ? `between ${moment(dates[0]).format('L')} and ${moment(dates[1]).format('L')}` : 'in Custom Date Range';
      break;
  }

  return result;
}

function rangeText (base, { operator, value }) {
  if (value.length === 0 || (value[1] == null && operator === 'less-than') || (value[0] == null && operator === 'more-than') || (value.some(x => x == null) && operator === 'between')) {
    return '';
  }

  let operatorText;

  switch (operator) {
    case 'more-than':
      operatorText = 'Greater Than';
      break;
    case 'less-than':
      operatorText = 'Less Than';
      break;
    case 'between':
      operatorText = 'Between';
      break;
  }

  let countText;

  const [start, end] = value;

  switch (operator) {
    case 'more-than':
      countText = numberShorthand(start);
      break;
    case 'less-than':
      countText = numberShorthand(end);
      break;
    case 'between':
      countText = `${numberShorthand(start)} and ${numberShorthand(end)}`;
      break;
  }

  let itemText;

  switch (base) {
    case 'Rating':
      itemText = ' Stars';
      break;
    case 'Advertising on':
      itemText = ' Networks';
      break;
    default:
      itemText = '';
  }

  return `${base} ${operatorText} ${countText}${itemText}`;
}

function rankingsText ({ eventType, dateRange, operator, trendOperator, values, charts, iosCategories, androidCategories, countries }) {
  if (['rank', 'trend'].includes(eventType.value) && values.length === 0) {
    return null;
  }

  let predicate;

  let operatorLabel = operator;

  if (eventType.value === 'rank') {
    if (operator === 'more-than') operatorLabel = 'above';
    if (operator === 'less-than') operatorLabel = 'below';
  } else if (eventType.value === 'trend') {
    if (operator === 'more-than') operatorLabel = 'more than';
    if (operator === 'less-than') operatorLabel = 'less than';
  }

  switch (eventType.value) {
    case 'rank':
      predicate = `${operatorLabel} ${_.compact(values).join(' and ')}`;
      break;
    case 'trend':
      predicate = `${trendOperator} ${operatorLabel} ${_.compact(values).join(' and ')} places in the last ${dateRange.label.toLowerCase()}`;
      break;
    case 'newcomer':
      predicate = `in the last ${dateRange.label.toLowerCase()}`;
      break;
  }

  return `Apps that ${eventType.label} ${predicate}`;
}

export default getDisplayText;
