/* eslint react/prop-types: 1 */
import React from 'react';
import { Pagination } from 'react-bootstrap';

const ReactUltimatePagination = require('react-ultimate-pagination');


function Page(props) {
  return (
    <li className={`pagination-page ${props.isActive ? 'active' : ''}`}>
      <a onClick={props.onClick} disabled={props.isDisabled}>{props.value}</a>
    </li>
  );
}

function Ellipsis(props) {
  return (
    <li className="pagination-page">
      <a onClick={props.onClick} disabled={props.isDisabled}>...</a>
    </li>
  );
}

function FirstPageLink(props) {
  return (
    <li className="pagination-first">
      <a onClick={props.onClick} disabled={props.isDisabled}>First</a>
    </li>
  );
}

function PreviousPageLink(props) {
  return (
    <li className="pagination-prev">
      <a onClick={props.onClick} disabled={props.isDisabled}>Previous</a>
    </li>
  );
}

function NextPageLink(props) {
  return (
    <li className="pagination-next">
      <a onClick={props.onClick} disabled={props.isDisabled}>Next</a>
    </li>
  );
}

function LastPageLink(props) {
  return (
    <li className="pagination-last">
      <a onClick={props.onClick} disabled={props.isDisabled}>Last</a>
    </li>
  );
}

function Wrapper(props) {
  return <Pagination bsSize="small">{props.children}</Pagination>;
}

const itemTypeToComponent = {
  'PAGE': Page,
  'ELLIPSIS': Ellipsis,
  'FIRST_PAGE_LINK': FirstPageLink,
  'PREVIOUS_PAGE_LINK': PreviousPageLink,
  'NEXT_PAGE_LINK': NextPageLink,
  'LAST_PAGE_LINK': LastPageLink
};

const UltimatePagination = ReactUltimatePagination.createUltimatePagination({
  itemTypeToComponent: itemTypeToComponent,
  WrapperComponent: Wrapper,
});

export default UltimatePagination;
