import angular from 'angular';
import $ from 'jquery';

(function() {
  'use strict';

  angular
    .module('appApp')
    .service('galleryUtils', galleryUtils);

  galleryUtils.$inject = ['$rootScope', '$sce'];

  function galleryUtils($rootScope, $sce) {
    return {
      addAdIds,
      getPreviousCreativePage,
      initializeCreativeFilters,
      resetVideos,
      rotateIframe,
      trustSrc
    }

    function addAdIds (ads) {
      if (ads) {
        for (var i = 0; i < ads.length; i++) {
          var ad = ads[i];
          ad.id = i;
        }
      }
      return ads;
    }

    function getPreviousCreativePage (creativeCount, pageSize, currentPageNum) {
      const lastPossiblePage = Math.ceil(creativeCount / pageSize)
      const newPage = currentPageNum == 1 ? lastPossiblePage : currentPageNum - 1
      return newPage
    }

    function initializeCreativeFilters (sources, formats) {
      const iconMap = {
        'html': 'html5',
        'image': 'picture-o',
        'video': 'film'
      }
      const filters = { networks: [], formats: [] }
      sources.forEach(source => {
        if (source.number_of_creatives) {
          filters.networks.push({ id: source.id, label: source.name})
        }
      })
      formats.forEach(format => filters.formats.push({ id: format, label: format, icon: iconMap[format] }))
      return filters;
    }

    function resetVideos (activeCreative) {
      const videos = $('.creative-video')
      $.each(videos, function (idx, video) {
        if (video.currentSrc != activeCreative.url) {
          video.pause()
          video.volume = 1;
          video.muted = false;
          video.currentTime = 0;
        }
      })
    }

    function rotateIframe () {
      const iframe = $('iframe')[0]
      if (iframe.width == "600px") {
        iframe.width = "400px"
        iframe.height = "600px"
      } else {
        iframe.width = "600px"
        iframe.height = "400px"
      }
      iframe.src = iframe.src
    }

    function trustSrc (source) {
      return $sce.trustAsResourceUrl(source)
    }
  }
})();
