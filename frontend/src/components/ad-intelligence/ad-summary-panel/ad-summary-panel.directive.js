import angular from 'angular';
import React from 'react';
import ReactDOM from 'react-dom';

import AdSummaryPanel from './AdSummary.component';

angular
  .module('appApp')
  .directive('adSummaryPanel', adSummaryPanel);

function adSummaryPanel() {
  const directive = {
    restrict: 'E',
    template: '<div></div>',
    scope: {
      firstSeenDate: '=',
      lastSeenDate: '=',
      adSdks: '=',
      platform: '=',
      formats: '=',
      numCreatives: '=',
      itemId: '=',
      itemType: '=',
      totalApps: '=',
    },
    link (scope, element) {
      ReactDOM.render(
        <AdSummaryPanel
          firstSeenDate={scope.firstSeenDate}
          lastSeenDate={scope.lastSeenDate}
          adSdks={scope.adSdks}
          platform={scope.platform}
          formats={scope.formats}
          numCreatives={scope.numCreatives}
          itemId={scope.itemId}
          itemType={scope.itemType}
          totalApps={scope.totalApps}
        />,
        element[0],
      );
    },
  };

  return directive;
}
