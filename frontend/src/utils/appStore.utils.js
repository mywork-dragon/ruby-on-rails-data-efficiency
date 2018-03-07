export function formatCategories (categories) {
  const result = {};

  categories.forEach((category) => {
    if (!result[category.id]) {
      result[category.id] = category;
    } else {
      result[category.id] = Object.assign({}, result[category.id], category);
    }

    if (category.parent) {
      if (!result[category.parent.id] || !result[category.parent.id].subCategories) {
        result[category.parent.id] = Object.assign({}, result[category.parent.id], { subCategories: [] });
      }
      result[category.parent.id].subCategories.push(category);
    }
  });

  return result;
}
