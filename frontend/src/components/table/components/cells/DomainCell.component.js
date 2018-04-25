import React from 'react';
import PropTypes from 'prop-types';
import { Popover, OverlayTrigger } from 'react-bootstrap';

const DomainCell = ({
  domains,
}) => {
  if (!domains || domains.length === 0) {
    return <span className="invalid">No domains</span>;
  }

  const popover = (
    <Popover id="popover-trigger-hover-focus">
      <ul className="international-data">
        {domains.map(x => (
          <li key={`domain_${x}`}>
            <a className="dotted-link" href={`https://${x}`} target="blank">{x}</a>
          </li>
        ))}
      </ul>
    </Popover>
  );

  return (
    <div>
      <OverlayTrigger overlay={popover} placement="left" rootClose trigger="click">
        <div>
          <span className="dotted-link">
            <span>{`${domains.length} domain${domains.length > 1 ? 's' : ''}`}</span>
          </span>
        </div>
      </OverlayTrigger>
    </div>
  );
};

DomainCell.propTypes = {
  domains: PropTypes.arrayOf(PropTypes.string),
};

DomainCell.defaultProps = {
  domains: null,
};

export default DomainCell;
