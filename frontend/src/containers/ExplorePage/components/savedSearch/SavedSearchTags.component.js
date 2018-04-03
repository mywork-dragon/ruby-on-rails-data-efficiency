import React from 'react';
import PropTypes from 'prop-types';
import { Tag } from 'antd';
import { capitalize } from 'utils/format.utils';

const SavedSearchTags = ({
  formState,
}) => {
  const tags = [];
  const form = JSON.parse(formState);

  tags.push(`Platform: ${capitalize(form.platform)}`);
  if (form.includeTakenDown) tags.push('Include Taken Down Apps');
  for (const key in form.filters) {
    if (form.filters[key]) {
      if (key === 'sdks') {
        form.filters[key].filters.forEach((x) => {
          if (x.displayText.length > 0) {
            tags.push(x.displayText);
          }
        });
      } else {
        const text = form.filters[key].displayText;
        if (text.length > 0) {
          tags.push(text);
        }
      }
    }
  }

  return (
    <div className="saved-search-tags-container">
      {tags.map((tag, idx) => <Tag key={`${tag}_${idx}`} color="blue">{tag}</Tag>)}
    </div>
  );
};

SavedSearchTags.propTypes = {
  formState: PropTypes.string.isRequired,
};

export default SavedSearchTags;
