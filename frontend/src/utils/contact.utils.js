

export function attachGetCompanyContactsLoader(object, promise) {
  /* Accepts an object and a promise  and attaches the necessary handlers
  to load contacts.
  */
  object.contactFetchComplete = false;
  return promise.then((data) => {
    object.contacts = data.contacts;
    object.contactsCount = data.contactsCount;
    if (!object.contacts.length) {
      object.contactMessage = "Sorry, No Contacts Available";
    }
  }).catch(error => {
    object.contacts = [];
    object.contactsCount = 0;
    if (error.status == 429) {
      object.contactMessage = error.data.error;
    } else {
      object.contactMessage = "Error fetching contacts...sorry.";
    }
  }).finally(() => {
    object.contactFetchComplete = true;
  })
}
