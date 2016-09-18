#pragma once

#include "storage/index.hpp"
#include "storage/storage_defines.hpp"

#include "indexer/feature.hpp"
#include "geometry/rect2d.hpp"

#include "std/function.hpp"

namespace df
{

class MapDataProvider
{
public:
  template <typename T> using TReadCallback = function<void (T const &)>;
  using TReadFeaturesFn = function<void (TReadCallback<FeatureType> const & , vector<FeatureID> const &)>;
  using TReadIDsFn = function<void (TReadCallback<FeatureID> const & , m2::RectD const &, int)>;
  using TIsCountryLoadedFn = function<bool (m2::PointD const &)>;
  using TIsCountryLoadedByNameFn = function<bool (string const &)>;
  using TUpdateCurrentCountryFn = function<void (m2::PointD const &, int)>;
  using TCoordinateCheckerFn = function<bool (ms::LatLon coord)>;

  typedef function<vector<TripfingerMark>(TripfingerMarkParams&)> TPoiSupplierCallback;

  TPoiSupplierCallback m_poiSupplierCallback;

  MapDataProvider(TReadIDsFn const & idsReader,
                  TReadFeaturesFn const & featureReader,
                  TIsCountryLoadedByNameFn const & isCountryLoadedByNameFn,
                  TUpdateCurrentCountryFn const & updateCurrentCountryFn,
                  TCoordinateCheckerFn const & coordinateCheckerFn,
                  TPoiSupplierCallback const & poiSupplierFn);

  void ReadFeaturesID(TReadCallback<FeatureID> const & fn, m2::RectD const & r, int scale) const;
  void ReadFeatures(TReadCallback<FeatureType> const & fn, vector<FeatureID> const & ids) const;

  TUpdateCurrentCountryFn const & UpdateCurrentCountryFn() const;

private:
  TReadFeaturesFn m_featureReader;
  TReadIDsFn m_idsReader;
  TUpdateCurrentCountryFn m_updateCurrentCountry;

public:
  TIsCountryLoadedByNameFn m_isCountryLoadedByName;
  TCoordinateCheckerFn m_coordinateCheckerFn;
};

} // namespace df
