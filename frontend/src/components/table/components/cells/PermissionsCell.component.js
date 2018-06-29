import React from 'react';
import PropTypes from 'prop-types';
import { Popover, OverlayTrigger } from 'react-bootstrap';

const PermissionsCell = ({
  permissions,
}) => {
  if (!permissions || permissions.length === 0) {
    return <span className="invalid">{!permissions ? 'N/A' : 'No permissions'}</span>;
  }

  const popover = (
    <Popover id="popover-trigger-hover-focus">
      <ul className="international-data">
        {permissions.map((x, i) => (
          <li key={`${x.identifier}_${i}`}>
            {x.display}
          </li>
        ))}
      </ul>
    </Popover>
  );

  const base = (
    <div>
      <span className={`${permissions.length > 1 ? 'tooltip-item' : ''}`}>
        <span>{permissions[0].display}</span>
      </span>
    </div>
  );

  if (permissions.length <= 1) return base;

  return (
    <div>
      <OverlayTrigger overlay={popover} placement="left" rootClose trigger={['hover', 'focus']}>
        {base}
      </OverlayTrigger>
    </div>
  );
};

PermissionsCell.propTypes = {
  permissions: PropTypes.arrayOf(PropTypes.object),
};

PermissionsCell.defaultProps = {
  permissions: null,
};

export default PermissionsCell;
