import React from 'react';
import PropTypes from 'prop-types';

const PublisherCell = ({ platform, publisher }) => (
  <div>
    {publisher ? (
      <a className="dotted-link pub-link" href={`#/publisher/${platform}/${publisher.id}`} target="_blank">
        {(publisher.icon || publisher.icon_url) && <img src={publisher.icon || publisher.icon_url} />}
        {' '}
        {publisher.name}
      </a>
    ) : <span className="invalid">Not available</span>}
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
