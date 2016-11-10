#pragma once

#include "indexer/feature.hpp"
#include "std/vector.hpp"
#include "std/map.hpp"
#include "std/set.hpp"

/*
 * Feature cache to allow non-asynchronous lookup of non-OSM features.
 */
class FeatureCache {

public:
  void SetFeatures(vector<SelfBakedFeatureType> &&);
  vector<SelfBakedFeatureType> GetFeatures(TripfingerMarkParams const & params) const;
  SelfBakedFeatureType GetFeatureById(string const & id) const;

private:
  map<string, const SelfBakedFeatureType> featureMap;
  set<string> coordinateSet;
};