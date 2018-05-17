/* eslint-env jest */

import { updateCategories, updateHeadquarters } from 'utils/explore/formStateValidation.utils';
import { androidCategories, iosCategories } from 'utils/mocks/mock-categories.utils';

test('form validation converts old category filters into new ones', () => {
  const oldForm = {
    filters: {
      iosCategories: {
        value: [
          { value: '36', label: 'Overall' },
          { value: '6000', label: 'Business' },
        ],
        panelKey: '2',
      },
      androidCategories: {
        value: [
          { value: 'GAME', label: 'Games' },
          { value: 'PARENTING', label: 'Parenting' },
        ],
        panelKey: '2',
      },
    },
  };

  const newForm = {
    filters: {
      categories: {
        value: [
          {
            value: 'Overall',
            label: 'Overall',
            ios: '36',
            android: 'OVERALL',
          },
          {
            value: 'Business',
            label: 'Business',
            ios: '6000',
            android: 'BUSINESS',
          },
          {
            value: 'Games',
            label: 'Games',
            ios: '6014',
            android: 'GAME',
          },
          {
            value: 'Parenting',
            label: 'Parenting',
            ios: null,
            android: 'PARENTING',
          },
        ],
        panelKey: '2',
        displayText: 'Categories: Overall, Business, Games, Parenting',
      },
    },
  };

  const result = updateCategories(oldForm, iosCategories, androidCategories);

  expect(result).toMatchObject(newForm);
});

test('form validation converts old headquarter filters', () => {
  const oldForm = {
    filters: {
      headquarters: {
        panelKey: '3',
        value: [
          { key: 'US', label: 'United States' },
          { key: 'IL', label: 'Israel' },
        ],
      },
    },
  };

  const newForm = {
    filters: {
      headquarters: {
        panelKey: '3',
        value: {
          values: [
            { value: 'US', label: 'United States', country: 'US' },
            { value: 'IL', label: 'Israel', country: 'IL' },
          ],
          operator: 'any',
          includeNoHqData: false,
        },
        displayText: 'Headquartered in any of: United States, Israel',
      },
    },
  };

  const result = updateHeadquarters(oldForm);

  expect(result).toMatchObject(newForm);
});
