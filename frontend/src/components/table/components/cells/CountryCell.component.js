import React from 'react';
import PropTypes from 'prop-types';

const CountryCell = ({
  requestCountries,
  shouldFetchCountries,
  getCountryById,
  country: countryId,
}) => {
  if (shouldFetchCountries) requestCountries();

  const country = getCountryById(countryId);

  return (
    <div style={{ margin: 5 }}>
      <img src={`/lib/images/flags/${countryId.toLowerCase()}.png`} style={{ marginRight: 5, height: 16 }} />
      {country ? country.name : countryId}
    </div>
  );
};

CountryCell.propTypes = {
  requestCountries: PropTypes.func.isRequired,
  shouldFetchCountries: PropTypes.bool.isRequired,
  country: PropTypes.string,
  getCountryById: PropTypes.func.isRequired,
};

CountryCell.defaultProps = {
  country: '',
};

export default CountryCell;
