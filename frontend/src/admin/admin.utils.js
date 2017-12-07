import angular from 'angular'
import moment from 'moment'

angular
.module('appApp')
.service('adminUtils', adminUtils);

function adminUtils() {
  return {
    lastUsedClass,
    range
  }

  function lastUsedClass (last_used) {
    var days = moment(moment()).diff(last_used, 'days')
    if(days <= 7) {
      return 'green';
    } else if(7 < days && days <= 14) {
      return 'yellow'
    } else if(14 < days && days <= 30) {
      return 'orange';
    } else {
      return 'red';
    }
  }

  function range (n) {
    const arr = []
    for (let i = 0; i <= n; i++) {
      arr.push(i)
    }
    return arr;
  }
}
