import moment from 'moment';

const shortDate = date => moment(date).format('MM/DD/YYYY');

export { shortDate };
