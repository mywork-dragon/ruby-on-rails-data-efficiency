import React from 'react';
import PropTypes from 'prop-types';
import { calculateDaysAgo } from 'utils/format.utils';

class FacebookCarousel extends React.Component {
  constructor () {
    super();

    this.handleSelect = this.handleSelect.bind(this);

    this.state = { activeIndex: 0 };
  }

  handleSelect(direction) {
    let newIndex = this.state.activeIndex + direction;
    if (newIndex > this.props.ads.length - 1) newIndex = 0;
    if (newIndex < 0) newIndex = this.props.ads.length - 1;
    this.setState({ activeIndex: newIndex });
  }

  render() {
    const { ads } = this.props;
    const { activeIndex } = this.state;

    if (ads.length === 0) return null;

    const slideAds = ads.slice(activeIndex, activeIndex + 10);

    return (
      <div className="panel panel-default">
        <div className="panel-heading"><strong>Facebook Ads</strong></div>
        <div className="panel-body">
          <div className="carousel slide" id="adIntelligenceCarousel">
            <ol className="carousel-indicators">
              <li className="active" />
              <li />
            </ol>
            <div className="carousel-inner">
              {slideAds.map((ad, idx) => (
                <div className="carousel-inner" key={ad.ad_image}>
                  <div className={`item text-center ${idx === 0 ? 'active' : ''}`}>
                    <div className="ad-container">
                      <img
                        src={ad.ad_image}
                        className={ad.ad_info_image ? 'ad-slide' : 'single-ad-slide'}
                      />
                      {ad.ad_info_image && (
                        <img
                          src={ad.ad_info_image}
                          className="ad-slide"
                        />
                      )}
                    </div>
                  </div>
                  <div className="carousel-caption">
                    <p>Spotted {calculateDaysAgo(ad.date_seen)} - {activeIndex + 1} of {ads.length}</p>
                  </div>
                </div>
              ))}
            </div>
            {ads.length > 1 && (
              <a className="left carousel-control" onClick={() => this.handleSelect(-1)} role="button" tabIndex={0}>
                <span className="glyphicon glyphicon-chevron-left" />
                <span className="sr-only">next</span>
              </a>
            )}
            {ads.length > 1 && (
              <a className="right carousel-control" onClick={() => this.handleSelect(1)} role="button" tabIndex={0}>
                <span className="glyphicon glyphicon-chevron-right" />
                <span className="sr-only">next</span>
              </a>
            )}
          </div>
        </div>
      </div>
    );
  }
}

FacebookCarousel.propTypes = {
  ads: PropTypes.arrayOf(PropTypes.object),
};

FacebookCarousel.defaultProps = {
  ads: [],
};

export default FacebookCarousel;
