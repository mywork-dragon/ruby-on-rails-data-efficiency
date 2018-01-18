import angular from 'angular';
import moment from 'moment';

angular
  .module('appApp')
  .service('adminUtils', adminUtils);

function adminUtils() {
  return {
    lastUsedClass,
    range,
  };

  function lastUsedClass (lastUsed) {
    const days = moment(moment()).diff(lastUsed, 'days');
    if (days <= 7) {
      return 'green';
    } else if (days > 7 && days <= 14) {
      return 'yellow';
    } else if (days > 14 && days <= 30) {
      return 'orange';
    }
    return 'red';
  }

  function range (n) {
    const arr = [];
    for (let i = 0; i <= n; i++) {
      arr.push(i);
    }
    return arr;
  }
}
