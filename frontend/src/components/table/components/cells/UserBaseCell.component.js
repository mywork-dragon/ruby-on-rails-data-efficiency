import React from 'react';
import PropTypes from 'prop-types';
import { Popover, OverlayTrigger } from 'react-bootstrap';

import { capitalize } from 'utils/format.utils';

const UserBaseCell = ({ app }) => {
  if (app.platform === 'ios' && app.userBases) {
    if (app.userBases.length === 1) {
      return (
        <div className="resultsTableAppUserbase">
          <span>
            <img src={`/lib/images/flags/${app.userBase.country_code.toLowerCase()}.png`} />
            {' '}
            {capitalize(app.userBase.user_base)}
          </span>
        </div>
      );
    } else if (app.platform === 'ios' && app.userBases.length > 1) {
      const popover = (
        <Popover id="popover-trigger-hover-focus">
          <ul className="international-data">
            { app.userBases.map(row => (
              <li key={row.country_code}>
                <div className={`flag flag-${row.country_code.toLowerCase()} pull-left`} />
                <span className="country">{row.country}:</span>
                <span>{capitalize(row.user_base)}</span>
              </li>
            ))}
          </ul>
        </Popover>
      );

      return (
        <div className="resultsTableAppUserbase">
          <OverlayTrigger overlay={popover} placement="left" trigger={['hover', 'focus']}>
            <div>
              <img src={`/lib/images/flags/${app.userBase.country_code.toLowerCase()}.png`} />
              {' '}
              <span className="tooltip-item">
                {capitalize(app.userBase.user_base)}
              </span>
            </div>
          </OverlayTrigger>
        </div>
      );
    }
  }

  const userBase = app.userBase || app.user_base || 'weak';

  return (
    <div className="resultsTableAppUserbase">
      <span>{capitalize(userBase)}</span>
    </div>
  );
};

UserBaseCell.propTypes = {
  app: PropTypes.shape({
    platform: PropTypes.string,
    userBase: PropTypes.object,
    userBases: PropTypes.array,
  }).isRequired,
};

export default UserBaseCell;
