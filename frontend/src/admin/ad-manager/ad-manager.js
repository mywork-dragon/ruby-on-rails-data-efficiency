import angular from 'angular'
import _ from 'lodash'

import './ad-manager.service'

angular
  .module('appApp')
  .controller('adManagerController', adManagerController);

adManagerController.$inject = ['adManagerService', 'id', '$sce', '$scope'];

function adManagerController(adManagerService, id, $sce, $scope) {
  var adManager = this;

  adManager.changesMade = false;
  adManager.id = id;
  adManager.networks = {}
  adManager.oldTiers = {}
  adManager.oldNetworks = {}
  adManager.tiers = {}

  adManager.saveSettings = saveSettings;
  adManager.updateTier = updateTier;
  adManager.updateNetwork = updateNetwork;

  activate();

  function activate() {
    getAccountSettings()
  }

  function getAccountSettings () {
    adManagerService.getAccountSettings(adManager.id)
      .then(data => {
        setData(data)
      })
      .then(() => {
      })
  }

  function saveSettings () {
    if (adManager.changesMade) {
      const settings = {
        ad_network_tiers: adManager.tiers,
        ad_networks: adManager.networks
      }
      adManagerService.updateAccountSettings(adManager.id, settings)
        .then(data => {
          setData(data)
        })
    }
  }

  function setData (data) {
    const tiers = setTierTooltips(data.ad_network_tiers)
    adManager.networks = data.ad_networks
    adManager.tiers = tiers
    adManager.oldNetworks = _.cloneDeep(data.ad_networks)
    adManager.oldTiers = _.cloneDeep(tiers)
    adManager.changesMade = false;
  }

  function setTierTooltips (tiers) {
    Object.values(tiers).forEach(tier => {
      const networks = tier.networks
      let template = '<div class="tier-tooltip"><ul>'
      networks.forEach(network => template += `<li>${network}</li>`)
      template += '</ul></div>'
      tier.tooltip = $sce.trustAsHtml(template)
    })

    return tiers
  }

  function updateNetwork(setting, id) {
    const network = adManager.networks[id]
    if (setting === 'hidden' && network.hidden) { network.can_access = false }
    if (setting === 'can_access' && network.can_access) { network.hidden = false }
  }

  function updateTier (id) {
    for (var tier in adManager.tiers) {
      adManager.tiers[tier].can_access = false;
    }
    const activeTier = adManager.tiers[id]
    activeTier.can_access = true;
    for (var name in adManager.networks) {
      const network = adManager.networks[name]
      if (activeTier.networks.includes(name) && !network.hidden) {
        network.can_access = true;
      } else {
        network.can_access = false;
      }
    }
  }

  $scope.$watch('adManager.networks', function (newVal, oldVal) {
    const populated = Object.values(adManager.oldNetworks).length
    if (populated) {
      adManager.changesMade = !angular.equals(newVal, adManager.oldNetworks)
    }
  }, true)

  $scope.$watch('adManager.tiers', function (newVal, oldVal) {
    const populated = Object.values(adManager.oldTiers).length
    if (populated) {
      adManager.changesMade = !angular.equals(newVal, adManager.oldTiers)
    }
  }, true)
}
