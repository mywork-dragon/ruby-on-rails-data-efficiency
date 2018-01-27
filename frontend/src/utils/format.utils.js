import moment from 'moment';

export const shortDate = date => moment(date).format('MM/DD/YYYY');

export const longDate = date => moment(date).format('MMM DD, YYYY');

export const capitalize = string => string.charAt(0).toUpperCase() + string.slice(1);

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

export function getUpdateDateClass (numDays) {
  if (numDays <= 60) {
    return 'last-updated-days-new';
  } else if (numDays > 60 && numDays < 181) {
    return 'last-updated-days-medium';
  }
  return 'last-updated-days-old';
}
