import { connect } from 'react-redux';
import { adNetworks } from 'actions/Account.actions';

import AdNetworkCell from '../components/cells/AdNetworkCell.component';

const mapDispatchToProps = dispatch => ({
  fetchAdNetworks: () => dispatch(adNetworks.request()),
});

const mapStateToProps = ({ account: { adNetworks: networksStore } }, { networks, showName }) => ({
  fetching: networksStore.fetching,
  networks,
  networksLoaded: networksStore.loaded,
  visibleNetworks: Object.values(networksStore.adNetworks),
  showName,
});

const AdNetworkCellContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(AdNetworkCell);

export default AdNetworkCellContainer;
