#pragma once

#include "drape_frontend/user_marks_provider.hpp"

#include "indexer/feature_decl.hpp"

#include "geometry/latlon.hpp"
#include "geometry/point2d.hpp"

#include "base/macros.hpp"

#include "std/string.hpp"
#include "std/unique_ptr.hpp"
#include "std/utility.hpp"


class UserMarkContainer;
class UserMarkCopy;

class TripfingerBookmark : public df::UserPointMark
{
public:
  TripfingerBookmark(ms::LatLon const & latLon);

  ///////////////////////////////////////////////////////
  /// df::UserPointMark
  m2::PointD const & GetPivot() const override;
  m2::PointD const & GetPixelOffset() const override;
  dp::Anchor GetAnchor() const override;
  float GetDepth() const override;
  ///////////////////////////////////////////////////////

  ms::LatLon GetLatLon() const;

protected:
  m2::PointD m_ptOrg;
};