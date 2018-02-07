import React from 'react';
import PropTypes from 'prop-types';

import PlayButton from './PlayButton.component';

const ThumbnailCell = ({ creative }) => {
  let thumbnail;

  const playVideo = () => {
    setTimeout(() => {
      document.getElementById('active-video').play();
    }, 2000);
  };

  if (creative.format === 'video') {
    thumbnail = (
      <td className="creative-cell thumbnail-cell" onClick={playVideo}>
        <div className="thumbnail-ctnr">
          <PlayButton />
          <video className="creative-thumbnail">
            <source src={`${creative.url}#t=6`} type="video/mp4" />
          </video>
        </div>
      </td>
    );
  } else {
    thumbnail = (
      <td className="thumbnail-cell creative-cell">
        <div className="thumbnail-ctnr">
          { creative.format === 'html' && <PlayButton /> }
          <img className="creative-thumbnail" src={creative.thumbnail || creative.url} />
        </div>
      </td>
    );
  }

  return thumbnail;
};

ThumbnailCell.propTypes = {
  creative: PropTypes.shape({
    format: PropTypes.string,
    url: PropTypes.string,
    thumbnail: PropTypes.string,
  }),
};

export default ThumbnailCell;
