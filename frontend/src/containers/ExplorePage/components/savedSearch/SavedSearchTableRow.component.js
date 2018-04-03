import React from 'react';
import PropTypes from 'prop-types';
import { Icon } from 'antd';
import classNames from 'classnames';
import { isCurrentQuery } from 'utils/explore/general.utils';
import { longDate } from 'utils/format.utils';
import SavedSearchTags from './SavedSearchTags.component';

const SavedSearchTableRow = ({
  search,
  loadSavedSearch,
  deleteSavedSearch,
}) => (
  <tr
    className={classNames({ active: isCurrentQuery(search.queryId) })}
    onClick={() => {
      // document.querySelector('.table-dynamic').scrollIntoView({ behavior: 'auto', block: 'nearest' });
      loadSavedSearch(search.id, search.queryId);
    }}
  >
    {/* <td>{search.id}</td> */}
    <td className="search-name">
      <span className="dotted-link">
        {search.name}
      </span>
    </td>
    <td>
      <SavedSearchTags formState={search.formState} />
    </td>
    <td>{longDate(search.created_at)}</td>
    <td style={{ textAlign: 'center' }}>
      <Icon
        className="delete-btn"
        onClick={(e) => { e.stopPropagation(); deleteSavedSearch(search.id); }}
        type="delete"
      />
    </td>
  </tr>
);

SavedSearchTableRow.propTypes = {
  search: PropTypes.shape({
    id: PropTypes.number,
    name: PropTypes.string,
    queryId: PropTypes.string,
    formState: PropTypes.string,
  }).isRequired,
  loadSavedSearch: PropTypes.func.isRequired,
  deleteSavedSearch: PropTypes.func.isRequired,
};

export default SavedSearchTableRow;
