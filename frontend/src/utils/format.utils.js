import moment from 'moment';

export const shortDate = date => moment(date).format('L');

export const longDate = date => moment(date).format('ll');

export const timeAgo = date => moment(date, 'YYYYMMDD').fromNow();

export const capitalize = string => string.charAt(0).toUpperCase() + string.slice(1);

export const camelCase = (string) => {
  const stripped = string.replace(/\s+/g, '');
  return stripped.charAt(0).toLowerCase() + stripped.slice(1);
};

export function getMaxDate (date1, date2) {
  date1 = new Date(date1);
  date2 = new Date(date2);
  return date1 >= date2 ? date1 : date2;
}

export function getMinDate (date1, date2) {
  date1 = new Date(date1);
  date2 = new Date(date2);
  return date1 <= date2 ? date1 : date2;
}

export const daysAgo = (date) => {
  const oldDate = moment(date);
  const today = moment();
  return today.diff(oldDate, 'days');
};

export function getUpdateDateClass (date) {
  const numDays = daysAgo(date);
  if (numDays <= 60) {
    return 'last-updated-days-new';
  } else if (numDays > 60 && numDays < 181) {
    return 'last-updated-days-medium';
  }
  return 'last-updated-days-old';
}
