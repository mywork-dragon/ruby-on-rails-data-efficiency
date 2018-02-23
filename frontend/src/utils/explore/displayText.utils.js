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

export default getDisplayText;
