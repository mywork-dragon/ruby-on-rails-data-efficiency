import React from 'react';
import $ from 'jquery';

const RotateButtonComponent = () => {
  const rotateIframe = () => {
    const iframe = $('iframe')[0];
    if (iframe.width === '600px') {
      iframe.width = '400px';
      iframe.height = '600px';
    } else {
      iframe.width = '600px';
      iframe.height = '400px';
    }
    iframe.src = iframe.src;
  };

  return (
    <div className="iframe-control">
      <button className="btn btn-bordered-info" onClick={rotateIframe}>
        <i className="fa fa-rotate-right" />
        {' '}
        Rotate
      </button>
    </div>
  );
};

export default RotateButtonComponent;
