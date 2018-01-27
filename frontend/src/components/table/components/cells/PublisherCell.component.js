import React from 'react';
import PropTypes from 'prop-types';

const PublisherCell = ({ id, platform, name }) => (
  <div className="resultsTableAppPublisher">
    <a className="dotted-link" href={`#/publisher/${platform}/${id}`}>{name}</a>
  </div>
);

PublisherCell.propTypes = {
  id: PropTypes.number.isRequired,
  platform: PropTypes.string.isRequired,
  name: PropTypes.string.isRequired,
};

export default PublisherCell;
