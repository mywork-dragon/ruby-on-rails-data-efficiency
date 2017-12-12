import React from 'react';
import { Popover, OverlayTrigger } from 'react-bootstrap';

const NoCreativesPopover = () => {
  const popover = (
    <Popover id="popover-positioned-right" title="Why no creatives?">
      In some cases we detect an ad and identify the advertised app, but are unable to extract the creative.
    </Popover>
  );

  return (
    <OverlayTrigger trigger={['hover', 'focus']} placement="right" overlay={popover}>
      <span className="fa fa-question-circle" />
    </OverlayTrigger>
  );
};

export default NoCreativesPopover;
