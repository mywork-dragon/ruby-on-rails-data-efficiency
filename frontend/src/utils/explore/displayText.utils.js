export function getDisplayText (parameter, value) {
  switch (parameter) {
    case 'app_category':
      return categoryText(value);
    default:
      return '';
  }
}

function categoryText (value) {
  const base = 'Categories: ';
  return base + value.join(', ');
}
