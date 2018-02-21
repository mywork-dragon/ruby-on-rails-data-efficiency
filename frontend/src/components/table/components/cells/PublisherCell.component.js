import React from 'react';
import PropTypes from 'prop-types';

const PublisherCell = ({ platform, publisher: { id, name } }) => (
  <div className="resultsTableAppPublisher">
    <a className="dotted-link" href={`#/publisher/${platform}/${id}`}>{name}</a>
  </div>
);

PublisherCell.propTypes = {
  platform: PropTypes.string.isRequired,
  publisher: PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
  }).isRequired,
};

export default PublisherCell;
