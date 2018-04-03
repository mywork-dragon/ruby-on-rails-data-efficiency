export function formatCategories (categories) {
  const result = {};

  categories.forEach((category) => {
    if (category.name === 'Overall') {
      return;
    }

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

  if (result.FAMILY) {
    result.FAMILY.subCategories.forEach(x => delete result[x.id]);
    delete result.FAMILY;
  }

  return result;
}
