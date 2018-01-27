import { connect } from 'react-redux';
import { fetchAdNetworks } from 'actions/Account.actions';

import AdNetworkCell from '../components/cells/AdNetworkCell.component';

const mapDispatchToProps = dispatch => ({
  fetchAdNetworks: () => dispatch(fetchAdNetworks()),
});

const mapStateToProps = (store, ownProps) => ({
  fetching: store.account.adNetworks.fetching,
  networks: ownProps.networks,
  networksLoaded: store.account.adNetworks.loaded,
  visibleNetworks: Object.values(store.account.adNetworks.adNetworks),
  showName: ownProps.showName,
});

const AdNetworkCellContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(AdNetworkCell);

export default AdNetworkCellContainer;
