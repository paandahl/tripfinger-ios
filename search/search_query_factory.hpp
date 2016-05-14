#pragma once

#include "search/suggest.hpp"
#include "search/v2/search_query_v2.hpp"

#include "std/unique_ptr.hpp"
#include "geometry/point2d.hpp"

namespace storage
{
class CountryInfoGetter;
}

namespace search
{
class SearchQueryFactory
{
public:
  using TPoiSearchFn = function<vector<TripfingerMark> (search::TripfingerSearchParams const &)>;
  using TPoiByIdFetcherFn = function<TripfingerMark (uint32_t id)>;
  using TCoordinateCheckerFn = function<bool (ms::LatLon const &)>;
  using TCountryCheckerFn = function<string (m2::PointD const &)>;
  TPoiSearchFn m_poiSearchFn;
  TCoordinateCheckerFn m_coordinateCheckerFn;
  TCountryCheckerFn m_countryCheckerFn;


  virtual ~SearchQueryFactory() = default;

  virtual unique_ptr<Query> BuildSearchQuery(Index & index, CategoriesHolder const & categories,
                                             vector<Suggest> const & suggests,
                                             storage::CountryInfoGetter const & infoGetter)
  {
    unique_ptr<Query> queryPtr = make_unique<v2::SearchQueryV2>(index, categories, suggests, infoGetter);
    queryPtr->m_poiSearchFn = m_poiSearchFn;
    queryPtr->m_coordinateCheckerFn = m_coordinateCheckerFn;
    queryPtr->m_countryCheckerFn = m_countryCheckerFn;
    return queryPtr;
  }
};
}  // namespace search
