module RankingsParamDenormalizer
  # TODO: Deprecate this module and create central storefronts file where this information is stored. The info in this module is
  # currently duplicated between varys, mightylib and docker-flow repositories.

  def country_code_to_ios(country_code)
    @@ITUNES_COUNTRY_MAP[country_code.to_s]
  end

  def ios_to_country_code(ios_storefront)
    @@ITUNES_COUNTRY_MAP_INVERTED[ios_storefront.to_s]
  end

  def rank_type_to_ios(rank_type)
    @@ITUNES_RANKING_TYPES[rank_type.to_s]
  end

  def ios_to_rank_type(ios_rank_type)
    @@ITUNES_RANKING_TYPES_INVERTED[ios_rank_type.to_s]
  end

  def rank_type_to_android(rank_type)
    @@PLAY_STORE_RANKING_TYPES[rank_type.to_s]
  end

  def android_to_rank_type(android_rank_type)
    @@PLAY_STORE_RANKING_TYPES_INVERTED[android_rank_type.to_s]
  end

  class << self

    @@PLAY_STORE_RANKING_TYPES = {
      "free" => "topselling_free",
      "paid" => "topselling_paid",
      "grossing" => "topgrossing"
    }

    @@ITUNES_RANKING_TYPES = {
      "free" => "27",
      "paid" => "30",
      "grossing" => "38"
    }

    @@ITUNES_COUNTRY_MAP = {
       "AE" => "143481",
       "AG" => "143540",
       "AI" => "143538",
       "AL" => "143575",
       "AM" => "143524",
       "AO" => "143564",
       "AR" => "143505",
       "AT" => "143445",
       "AU" => "143460",
       "AZ" => "143568",
       "BB" => "143541",
       "BE" => "143446",
       "BF" => "143578",
       "BG" => "143526",
       "BH" => "143559",
       "BJ" => "143576",
       "BM" => "143542",
       "BN" => "143560",
       "BO" => "143556",
       "BR" => "143503",
       "BS" => "143539",
       "BT" => "143577",
       "BW" => "143525",
       "BY" => "143565",
       "BZ" => "143555",
       "CA" => "143455",
       "CD" => "143582",
       "CH" => "143459",
       "CL" => "143483",
       "CN" => "143465",
       "CO" => "143501",
       "CR" => "143495",
       "CV" => "143580",
       "CY" => "143557",
       "CZ" => "143489",
       "DE" => "143443",
       "DK" => "143458",
       "DM" => "143545",
       "DO" => "143508",
       "DZ" => "143563",
       "EC" => "143509",
       "EE" => "143518",
       "EG" => "143516",
       "ES" => "143454",
       "FI" => "143447",
       "FJ" => "143583",
       "FM" => "143591",
       "FR" => "143442",
       "GB" => "143444",
       "GD" => "143546",
       "GH" => "143573",
       "GM" => "143584",
       "GR" => "143448",
       "GT" => "143504",
       "GW" => "143585",
       "GY" => "143553",
       "HK" => "143463",
       "HN" => "143510",
       "HR" => "143494",
       "HU" => "143482",
       "ID" => "143476",
       "IE" => "143449",
       "IL" => "143491",
       "IN" => "143467",
       "IS" => "143558",
       "IT" => "143450",
       "JM" => "143511",
       "JO" => "143528",
       "JP" => "143462",
       "KE" => "143529",
       "KG" => "143586",
       "KH" => "143579",
       "KN" => "143548",
       "KR" => "143466",
       "KW" => "143493",
       "KY" => "143544",
       "KZ" => "143517",
       "LA" => "143587",
       "LB" => "143497",
       "LC" => "143549",
       "LK" => "143486",
       "LR" => "143588",
       "LT" => "143520",
       "LU" => "143451",
       "LV" => "143519",
       "MD" => "143523",
       "MG" => "143531",
       "MK" => "143530",
       "ML" => "143532",
       "MN" => "143592",
       "MO" => "143515",
       "MR" => "143590",
       "MS" => "143547",
       "MT" => "143521",
       "MU" => "143533",
       "MW" => "143589",
       "MX" => "143468",
       "MY" => "143473",
       "MZ" => "143593",
       "NA" => "143594",
       "NE" => "143534",
       "NG" => "143561",
       "NI" => "143512",
       "NL" => "143452",
       "NO" => "143457",
       "NP" => "143484",
       "NZ" => "143461",
       "OM" => "143562",
       "PA" => "143485",
       "PE" => "143507",
       "PG" => "143597",
       "PH" => "143474",
       "PK" => "143477",
       "PL" => "143478",
       "PT" => "143453",
       "PW" => "143595",
       "PY" => "143513",
       "QA" => "143498",
       "RO" => "143487",
       "RU" => "143469",
       "SA" => "143479",
       "SB" => "143601",
       "SC" => "143599",
       "SE" => "143456",
       "SG" => "143464",
       "SI" => "143499",
       "SK" => "143496",
       "SL" => "143600",
       "SN" => "143535",
       "SR" => "143554",
       "ST" => "143598",
       "SV" => "143506",
       "SZ" => "143602",
       "TC" => "143552",
       "TD" => "143581",
       "TH" => "143475",
       "TJ" => "143603",
       "TM" => "143604",
       "TN" => "143536",
       "TR" => "143480",
       "TT" => "143551",
       "TW" => "143470",
       "TZ" => "143572",
       "UA" => "143492",
       "UG" => "143537",
       "US" => "143441",
       "UY" => "143514",
       "UZ" => "143566",
       "VC" => "143550",
       "VE" => "143502",
       "VG" => "143543",
       "VN" => "143471",
       "YE" => "143571",
       "ZA" => "143472",
       "ZW" => "143605"
    }

    @@PLAY_STORE_RANKING_TYPES_INVERTED = @@PLAY_STORE_RANKING_TYPES.invert
    @@ITUNES_RANKING_TYPES_INVERTED = @@ITUNES_RANKING_TYPES.invert
    @@ITUNES_COUNTRY_MAP_INVERTED = @@ITUNES_COUNTRY_MAP.invert

  end

end
