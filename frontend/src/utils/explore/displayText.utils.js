import { capitalize } from 'utils/format.utils';

export function getDisplayText (parameter, value) {
  switch (parameter) {
    case 'app_category':
      return categoryText(value);
    case 'mobilePriority':
      return mobilePriorityText(value);
    default:
      return '';
  }
}

function categoryText (value) {
  const base = 'Categories: ';
  return base + value.join(', ');
}

function mobilePriorityText (value) {
  const base = 'Mobile Priority: ';
  return base + value.map(x => capitalize(x)).join(', ');
}
