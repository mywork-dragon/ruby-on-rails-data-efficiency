import React from 'react';
import PropTypes from 'prop-types';

import { getAltUrl } from 'utils/ad-intelligence.utils';

import BlueLink from 'Links/BlueLink';

const ActiveCreativePreviewComponent = ({ format, url }) => {
  let preview;

  if (format === 'html') {
    preview = (
      <div>
        <div className="active-creative-media-ctnr">
          <iframe height="400px" src={url} title="playable" width="600px" />
        </div>
        <div className="html-help-prompt">
          Trouble loading? Click
          <BlueLink href={getAltUrl(url)} target="_blank">
            {' '}
            here
            {' '}
          </BlueLink>
          to open in a new window
        </div>
      </div>
    );
  } else if (format === 'image') {
    preview = (
      <div className="active-creative-media-ctnr">
        <img src={url} />
      </div>
    );
  } else if (format === 'video') {
    preview = (
      <div className="active-creative-media-ctnr">
        <video className="creative-video" controls id="active-video" src={url}>
          <source src={url} type="video/mp4" />
          <img src="images/fallback-elephant.png" />
        </video>
      </div>
    );
  }

  return preview;
};

ActiveCreativePreviewComponent.propTypes = {
  format: PropTypes.string.isRequired,
  url: PropTypes.string.isRequired,
};

export default ActiveCreativePreviewComponent;
