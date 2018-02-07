import { connect } from 'react-redux';
import { fetchAdNetworks } from 'actions/Account.actions';

import AdNetworkCell from '../components/cells/AdNetworkCell.component';

const mapDispatchToProps = dispatch => ({
  fetchAdNetworks: () => dispatch(fetchAdNetworks()),
});

const mapStateToProps = ({ account: { adNetworks } }, { networks, showName }) => ({
  fetching: adNetworks.fetching,
  networks,
  networksLoaded: adNetworks.loaded,
  visibleNetworks: Object.values(adNetworks.adNetworks),
  showName,
});

const AdNetworkCellContainer = connect(
  mapStateToProps,
  mapDispatchToProps,
)(AdNetworkCell);

export default AdNetworkCellContainer;
