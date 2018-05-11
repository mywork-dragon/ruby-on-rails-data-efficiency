/* eslint-env jest */

import { updateCategories } from 'utils/explore/formStateValidation.utils';
import { androidCategories, iosCategories } from 'utils/mocks/mock-categories.utils';

test('form validation converts old category filters into new ones', () => {
  const oldForm = {
    filters: {
      iosCategories: {
        value: [
          { value: '36', label: 'Overall' },
          { value: '6000', label: 'Business' },
        ],
      },
      androidCategories: {
        value: [
          { value: 'GAME', label: 'Games' },
          { value: 'PARENTING', label: 'Parenting'}
        ],
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
        displayText: 'Categories: Overall, Business, Games, Parenting',
      },
    },
  };

  const result = updateCategories(oldForm, iosCategories, androidCategories);

  expect(result).toMatchObject(newForm);
});
