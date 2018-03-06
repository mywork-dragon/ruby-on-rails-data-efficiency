import moment from 'moment';
import { capitalize } from 'utils/format.utils';

function getDisplayText (parameter, value) {
  switch (parameter) {
    case 'app_category':
      return categoryText(value);
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
    default:
      return '';
  }
}

function listText(base, value) {
  return base + value.map(x => capitalize(x)).join(', ');
}

function categoryText (value) {
  const base = 'Categories: ';
  return base + value.join(', ');
}

function sdkText ({ eventType, sdks, dateRange, dates }) {
  if (sdks.length === 0) {
    return '';
  }

  let eventTypeText;
  let dateText;

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
    case 'is-installed':
      eventTypeText = 'Currently Installed';
      break;
    case 'is-not-installed':
      eventTypeText = 'Currently Not Installed';
      break;
  }

  switch (dateRange) {
    case 'anytime':
      dateText = 'Anytime';
      break;
    case 'week':
      dateText = 'in the Last Week';
      break;
    case 'month':
      dateText = 'in the Last Month';
      break;
    case 'three-months':
      dateText = 'in the Last Three Months';
      break;
    case 'six-months':
      dateText = 'in the Last Six Months';
      break;
    case 'year':
      dateText = 'in the Last Year';
      break;
    case 'custom':
      dateText = dates[0] ? `between ${moment(dates[0]).format('L')} and ${moment(dates[1]).format('L')}` : 'in Custom Date Range';
      break;
  }

  const requiresDate = ['install', 'uninstall'].includes(eventType);

  return `${sdks.map(x => x.name).join(', ')} ${eventTypeText} ${requiresDate ? dateText : ''}`;
}

function headquarterText (countries) {
  return `Headquartered in ${countries.map(x => x.label).join(', ')}`;
}

export default getDisplayText;
