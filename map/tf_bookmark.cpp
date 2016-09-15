#include "map/tf_bookmark.hpp"
#include "map/user_mark_container.hpp"

#include "indexer/classificator.hpp"

#include "geometry/mercator.hpp"

#include "base/string_utils.hpp"

TripfingerBookmark::TripfingerBookmark(ms::LatLon const & latLon)
    : m_ptOrg(MercatorBounds::FromLatLon(latLon))
{
}

m2::PointD const & TripfingerBookmark::GetPivot() const
{
  return m_ptOrg;
}

m2::PointD const & TripfingerBookmark::GetPixelOffset() const
{
  static m2::PointD const s_centre(0.0, 0.0);
  return s_centre;
}

dp::Anchor TripfingerBookmark::GetAnchor() const
{
  return dp::Bottom;
}

float TripfingerBookmark::GetDepth() const
{
  return 0;
}

ms::LatLon TripfingerBookmark::GetLatLon() const
{
  return MercatorBounds::ToLatLon(m_ptOrg);
}