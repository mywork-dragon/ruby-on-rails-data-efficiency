import angular from 'angular';
import $ from 'jquery';

import 'utils/creative-gallery.utils';
import 'directives/fallback-src.directive';
import 'Mixpanel/creatives.mixpanel.service';

const template = require('./creative-gallery.html');

angular
  .module('appApp')
  .directive('creativeGallery', creativeGallery);

function creativeGallery() {
  const directive = {
    restrict: 'E',
    template,
    scope: {
      getCreativesCallback: '=',
      pageSize: '=',
      networks: '=',
      formats: '=',
      totalCreatives: '=',
      apps: '=',
      trackAppClick: '=',
      publisherName: '=',
    },
    controller: creativesController,
    controllerAs: 'gallery',
    bindToController: true,
  };

  return directive;
}

creativesController.$inject = ['$stateParams', 'galleryUtils', 'creativesMixpanelService'];

function creativesController($stateParams, galleryUtils, creativesMixpanelService) {
  const gallery = this;

  gallery.activeCreative = {};
  gallery.activeSlide = 0;
  gallery.creativeFetchComplete = false;
  gallery.filterOptions = { networks: [], formats: [] };
  gallery.filters = { networks: [], formats: [] };
  gallery.creatives = [];
  gallery.creativesCount = 0;
  gallery.currentPage = 1;
  gallery.dropdownEvents = {
    onSelectionChanged () {
      gallery.activeSlide = 0;
      getCreatives(1);
    },
  };
  gallery.dropdownSettings = {
    network: {
      buttonClasses: '',
      externalIdProp: '',
      dynamicTitle: false,
      showCheckAll: false,
      showUncheckAll: false,
      template: '<img class="popover-icon" ng-src="{{\'images/\' + option.id + \'.png\'}}" alt="icon" />{{option.label}}',
    },
    format: {
      buttonClasses: '',
      externalIdProp: '',
      dynamicTitle: false,
      showCheckAll: false,
      showUncheckAll: false,
      template: '<i class="{{\'fa fa-\' + option.icon}}" style="margin-right: 5px;"></i>{{option.label | capitalize}}',
    },
  };
  gallery.dropdownText = {
    network: { buttonDefaultText: 'NETWORKS' },
    format: { buttonDefaultText: 'FORMATS' },
  };
  gallery.initialCreativeFetchComplete = false;

  gallery.autoPlay = autoPlay;
  gallery.changeActiveSlide = changeActiveSlide;
  gallery.checkIfAdSource = checkIfAdSource;
  gallery.getCreatives = getCreatives;
  gallery.getAltUrl = galleryUtils.getAltUrl;
  gallery.rotateIframe = galleryUtils.rotateIframe;
  gallery.trackCreativeClick = creativesMixpanelService.trackCreativeClick;
  gallery.trackCreativePageThrough = creativesMixpanelService.trackCreativePageThrough;
  gallery.trackCreativeScroll = creativesMixpanelService.trackCreativeScroll;
  gallery.trustSrc = galleryUtils.trustSrc;

  activate();

  function activate() {
    gallery.platform = $stateParams.platform;
    gallery.id = $stateParams.id;
    initializeFilters();
    getCreatives().then(() => gallery.initialCreativeFetchComplete = true);
  }

  function autoPlay (id) {
    const video = $(`.video-${id}`)[0];
    video.play();
  }

  function changeActiveSlide (id) {
    const lastPossiblePage = Math.ceil(gallery.creativesCount / gallery.pageSize);
    if (id === gallery.creatives.length) {
      gallery.activeSlide = 0;
      gallery.activeCreative = gallery.creatives[0];
      if (gallery.currentPage === lastPossiblePage && lastPossiblePage !== 1) {
        gallery.currentPage = 1;
        getCreatives();
      } else if (gallery.currentPage < lastPossiblePage && lastPossiblePage !== 1) {
        gallery.currentPage += 1;
        getCreatives();
      }
    } else if (id === -1) {
      if (lastPossiblePage !== 1) {
        gallery.currentPage = gallery.currentPage === 1 ? lastPossiblePage : gallery.currentPage - 1;
        gallery.activeSlide = id;
        getCreatives();
      } else {
        gallery.activeSlide = gallery.creatives.length - 1;
        gallery.activeCreative = gallery.creatives[gallery.activeSlide];
      }
    } else {
      gallery.activeSlide = id;
      gallery.activeCreative = gallery.creatives[id];
      galleryUtils.resetVideos(gallery.activeCreative);
    }
  }

  function checkIfAdSource (id, sources) {
    return sources.some(source => source.id === id);
  }

  function getCreatives (pageNum = gallery.currentPage) {
    gallery.creativeFetchComplete = false;
    const activeNetworks = gallery.filters.networks.map(network => network.id);
    const activeFormats = gallery.filters.formats.map(format => format.id);
    return gallery.getCreativesCallback(gallery.platform, gallery.id, pageNum, gallery.pageSize, activeNetworks, activeFormats)
      .then((data) => {
        gallery.creatives = galleryUtils.addAdIds(data.results);
        gallery.creativesCount = data.resultsCount;
        gallery.currentPage = data.pageNum;
        gallery.creativeFetchComplete = true;
        gallery.activeSlide = gallery.activeSlide === -1 ? gallery.creatives.length - 1 : gallery.activeSlide;
        gallery.activeCreative = gallery.creatives[gallery.activeSlide];
      });
  }

  function initializeFilters () {
    gallery.filterOptions = galleryUtils.initializeCreativeFilters(gallery.networks, gallery.formats);
    gallery.filters = galleryUtils.initializeCreativeFilters(gallery.networks, gallery.formats);
  }
}
