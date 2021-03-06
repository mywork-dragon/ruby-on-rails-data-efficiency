import moment from 'moment';

export const shortDate = date => moment(date).format('L');

export const longDate = date => moment(date).format('ll');

export const timeAgo = date => moment(date, 'YYYYMMDD').fromNow();

export const capitalize = (string) => {
  if (string === 'ios') {
    return 'iOS';
  }

  return string.charAt(0).toUpperCase() + string.slice(1);
};

export const camelCase = (string) => {
  const stripped = string.replace(/\s+/g, '');
  return stripped.charAt(0).toLowerCase() + stripped.slice(1);
};

export const snakeCase = (string) => {
  const upperChars = string.match(/([A-Z])/g);
  if (!upperChars) {
    return this;
  }

  let str = string;
  for (let i = 0, n = upperChars.length; i < n; i++) {
    str = str.replace(new RegExp(upperChars[i]), `_${upperChars[i].toLowerCase()}`);
  }

  if (str.slice(0, 1) === '_') {
    str = str.slice(1);
  }

  return str;
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

export const calculateDaysAgo = (date, shortFormat) => {
  if (shortFormat) {
    moment.locale('en', {
      relativeTime: {
        future: 'in %s',
        past: '%s ago',
        s: 's',
        m: '1m',
        mm: '%dm',
        h: '1h',
        hh: '%dh',
        d: '1d',
        dd: '%dd',
        M: '1mo',
        MM: '%dmo',
        y: '1y',
        yy: '%dy',
      },
    });
  }
  return moment(date).fromNow();
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

export const numberShorthand = (x) => {
  var y = Math.abs(x);
  var sign = Math.sign(x);

  if (y < 1000) {
    return sign * y;
  } else if (y < 1000000) {
    return Math.round(sign * y / 1000).toString() + 'K';
  } else if (y < 1000000000) {
    return Math.round(sign * y / 1000000).toString() + 'M';
  } else if (y < 1000000000000) {
    return Math.round(sign * y / 1000000000).toString() + 'B';
  } else if (y < 1000000000000000) {
    return Math.round(sign * y / 1000000000000).toString() + 'T';
  } else {
    return x.toString();
  }
};

export const numberWithCommas = x => x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');

export const getNestedValue = (path, object) => path.reduce((xs, x) => (xs && xs[x] ? xs[x] : null), object);

export const subtractDays = x => moment().subtract(x, 'days').startOf('day');
