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

function sdkText ({ eventType, sdks }) {
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
    case 'is-installed':
      eventTypeText = 'Currently Installed';
      break;
    case 'is-not-installed':
      eventTypeText = 'Currently Not Installed';
      break;
  }

  return `${sdks.map(x => x.name).join(', ')} ${eventTypeText}`;
}

export default getDisplayText;
