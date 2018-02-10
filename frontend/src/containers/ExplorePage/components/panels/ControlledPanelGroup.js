import React from 'react';
import PropTypes from 'prop-types';
import { PanelGroup } from 'react-bootstrap';

const ControlledPanelGroup = ({ activeKey, children, handleSelect }) => (
  <PanelGroup
    accordion
    activeKey={activeKey}
    id="accordion-controlled-example"
    onSelect={handleSelect}
  >
    {children}
  </PanelGroup>
);

ControlledPanelGroup.propTypes = {
  activeKey: PropTypes.string.isRequired,
  children: PropTypes.arrayOf(PropTypes.element).isRequired,
  handleSelect: PropTypes.func.isRequired,
};

export default ControlledPanelGroup;
