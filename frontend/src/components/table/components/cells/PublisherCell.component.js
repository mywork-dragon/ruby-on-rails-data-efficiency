import React from 'react';
import PropTypes from 'prop-types';

const PublisherCell = ({ platform, publisher }) => (
  <div className="resultsTableAppPublisher">
    {publisher ? (
      <a className="dotted-link" href={`#/publisher/${platform}/${publisher.id}`} target="_blank">{publisher.name}</a>
    ) : <span>Not available</span>}
  </div>
);

PublisherCell.propTypes = {
  platform: PropTypes.string.isRequired,
  publisher: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
  }),
};

PublisherCell.defaultProps = {
  publisher: null,
};

export default PublisherCell;
