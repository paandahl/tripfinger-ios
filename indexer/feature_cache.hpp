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
  vector<SelfBakedFeatureType> Search(string const & query, bool includeHidden) const;
  SelfBakedFeatureType GetFeatureById(string const & id) const;

  void SetCategories(map<string, int> &&);
  int GetCategory(string const & category);

private:
  map<string, const SelfBakedFeatureType> featureMap;
  map<string, int> categoryMap;
  set<string> coordinateSet;
};