export const $localStorage = {
  set: (name, value) => localStorage.setItem(`mightySignal.${name}`, JSON.stringify(value)),
  get: name => JSON.parse(localStorage.getItem(`mightySignal.${name}`)),
  clearAll: clearAllFromLocalStorage,
};

function clearAllFromLocalStorage () {
  for (let key in localStorage) {
    if (new RegExp('^mightySignal.').test(key)) {
      localStorage.removeItem(key);
    }
  }
}
